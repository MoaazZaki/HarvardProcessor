LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY PipelinedProcessor IS
    GENERIC (
        n : INTEGER := 32);
    PORT (
        clk, reset : IN STD_LOGIC;
        INTSRUCTION : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        -- (31 DOWNTO 27)OPERATION 
        -- (26 DOWNTO 24)OP1 
        -- (23 DOWNTO 21)OP2 
        -- (20 DOWNTO 16)FUNCTION
        -- (20 DOWNTO 5)IMM
        OUTP : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END PipelinedProcessor;

ARCHITECTURE pipe OF PipelinedProcessor IS
    ---------------> Start of Components <--------------
    COMPONENT Registers IS
        GENERIC (
            REGS_NUM : INTEGER := 8;
            REGS_INDEX_SIZE : INTEGER := 3;
            n : INTEGER := 32);
        PORT (
            clk, reset, writeEnable : IN STD_LOGIC;
            OP1 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0);
            OP2 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0);
            WADDRESS : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0);
            WDATA : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            OUT1 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            OUT2 : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;
    --
    COMPONENT ALU IS
        GENERIC (N : INTEGER := 32);
        PORT (
            -- INPUT
            operand1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            operand2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            operation : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            func : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            -- OUTPUT
            result : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            flagsOUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;
    --
    COMPONENT RegisterDFF IS
        GENERIC (n : INTEGER := 32);
        PORT (
            clk, reset, enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;
    --
    COMPONENT ControlUnit IS
        GENERIC (N : INTEGER := 32);
        PORT (
            instruction : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            IshouldStall : IN STD_LOGIC;
            ALU_Src_ImmOrReg : OUT STD_LOGIC;
            ALU_Operation : OUT STD_LOGIC;
            MEM_Write : OUT STD_LOGIC;
            MEM_Read : OUT STD_LOGIC;
            MEM_useStack : OUT STD_LOGIC;
            WB_WBEnable : OUT STD_LOGIC;
            WB_MemToReg : OUT STD_LOGIC
        );
    END COMPONENT;
    --
    COMPONENT RAM IS
        GENERIC (
            STORED_DATA_SIZE : INTEGER := 16;
            ADRESS_SIZE : INTEGER := 20;
            RAM_SIZE : INTEGER := 2 ** 20);
        PORT (
            clk, reset : IN STD_LOGIC;
            we : IN STD_LOGIC;
            address : IN STD_LOGIC_VECTOR(ADRESS_SIZE - 1 DOWNTO 0);
            datain : IN STD_LOGIC_VECTOR(STORED_DATA_SIZE - 1 DOWNTO 0);
            dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE - 1 DOWNTO 0));
    END COMPONENT;
    ---------------> End of Components <--------------
    ---------------> Start of Signals <--------------
    ---------------> Decode Signals <--------------
    SIGNAL DECODEOUT1 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL DECODEOUT2 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    ---------------> Execute Signals <--------------
    SIGNAL ID_EX_IN : STD_LOGIC_VECTOR(101 - 1 DOWNTO 0);
    SIGNAL ID_EX_OUT : STD_LOGIC_VECTOR(101 - 1 DOWNTO 0);
    --(100 DOWNTO 100)ALU_op
    --(99 DOWNTO 99)ALU_src
    --(98 DOWNTO 98)flag_set
    --(97 DOWNTO 97)UseStack 
    --(96 DOWNTO 96)MemRead 
    --(95 DOWNTO 95)MemWrite 
    --(94 DOWNTO 94)WBEnable 
    --(93 DOWNTO 93)MemToReg  
    --(92 DOWNTO 77)IMM 
    --(76 DOWNTO 74)OP1 
    --(73 DOWNTO 69)OPERATION  
    --(68 DOWNTO 64)FUNCTION/SHIFT VAL
    --(63 DOWNTO 32)DECODEOUT2
    --(31 DOWNTO 0)DECODEOUT1 
    SIGNAL ALU_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL ALU_FLAGS_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- (0) ZERO_FLAG
    -- (1) NEGATIVE_FLAG
    -- (2) CARRY_FLAG
    ---------------> Memory Signals <--------------
    SIGNAL EX_MEM_IN : STD_LOGIC_VECTOR(72 - 1 DOWNTO 0);
    SIGNAL EX_MEM_OUT : STD_LOGIC_VECTOR(72 - 1 DOWNTO 0);
    --(71 DOWNTO 71)UseStack 
    --(70 DOWNTO 70)MemRead 
    --(69 DOWNTO 69)MemWrite 
    --(68 DOWNTO 68)WBEnable 
    --(67 DOWNTO 67)MemToReg  
    --(66 DOWNTO 35)ALU OUT
    --(34 DOWNTO 3)OP2 VALUE
    --(2 DOWNTO 0)OP1 
    SIGNAL MEM_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    ---------------> Write back Signals <--------------
    SIGNAL MEM_WB_IN : STD_LOGIC_VECTOR(69 - 1 DOWNTO 0);
    SIGNAL MEM_WB_OUT : STD_LOGIC_VECTOR(69 - 1 DOWNTO 0);
    --(68 DOWNTO 68)WBEnable 
    --(67 DOWNTO 67)MemToReg  
    --(66 DOWNTO 35) MEMORY_OUT
    --(34 DOWNTO 3) ALU_OUT
    --(2 DOWNTO 0) OP1 ADRESS
    ---------------> Control Signals <--------------
    SIGNAL CNT_SRC_IS_IMM : STD_LOGIC;
    SIGNAL CNT_IS_ALU_OPERATION : STD_LOGIC;
    SIGNAL CNT_IS_MEM_WRITE : STD_LOGIC;
    SIGNAL CNT_IS_MEM_READ : STD_LOGIC;
    SIGNAL CNT_IS_STACK : STD_LOGIC;
    SIGNAL CNT_WB_IS_ON : STD_LOGIC;
    SIGNAL CNT_WB_TO_MEM : STD_LOGIC;
    ---------------> Signals use Control Selectors <--------------
    SIGNAL WRTIE_TO_REG : STD_LOGIC;
    SIGNAL OPERAND2 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    ---------------> End of Signals <--------------
BEGIN
    WRTIE_TO_REG <= '1'
        WHEN
        CNT_WB_IS_ON = '1'
        ELSE
        '0';
    -- Decoding stage
    REG_READ_WRITE : Registers PORT MAP(clk, reset, WRTIE_TO_REG, INTSRUCTION(26 DOWNTO 24), INTSRUCTION(23 DOWNTO 21), MEM_WB_OUT(34 DOWNTO 32), MEM_WB_OUT(31 DOWNTO 0), DECODEOUT1, DECODEOUT2);
    CONTROL_UNIT : ControlUnit PORT MAP(INTSRUCTION, '0', CNT_SRC_IS_IMM, CNT_IS_ALU_OPERATION, CNT_IS_MEM_WRITE, CNT_IS_MEM_READ, CNT_IS_STACK, CNT_WB_IS_ON, CNT_WB_TO_MEM);
    -- Execute Stage
    ID_EX_IN <= CNT_IS_ALU_OPERATION & CNT_SRC_IS_IMM & CNT_IS_ALU_OPERATION & CNT_IS_STACK & CNT_IS_MEM_READ & CNT_IS_MEM_WRITE & CNT_WB_IS_ON & CNT_WB_TO_MEM & INTSRUCTION(20 DOWNTO 5) & INTSRUCTION(26 DOWNTO 24) & INTSRUCTION(31 DOWNTO 27) & INTSRUCTION(20 DOWNTO 16) & DECODEOUT2 & DECODEOUT1;
    ID_EX_REG : RegisterDFF GENERIC MAP(101) PORT MAP(clk, reset, '1', ID_EX_IN, ID_EX_OUT);
    OPERAND2 <= (31 DOWNTO 16 => ID_EX_OUT(92)) & ID_EX_OUT(92 DOWNTO 77) -- Immediate with Sign extend
        WHEN
        ID_EX_OUT(99) = '1'
        ELSE
        ID_EX_OUT(63 DOWNTO 32);
    ALU_MODULE : ALU PORT MAP(ID_EX_OUT(31 DOWNTO 0), OPERAND2, ID_EX_OUT(73 DOWNTO 69), ID_EX_OUT(68 DOWNTO 64), ALU_OUT, ALU_FLAGS_OUT);
    -- Memory Stage
    EX_MEM_IN <= CNT_IS_STACK & CNT_IS_MEM_READ & CNT_IS_MEM_WRITE & CNT_WB_IS_ON & CNT_WB_TO_MEM & ALU_OUT & ID_EX_OUT(63 DOWNTO 32) & ID_EX_OUT(76 DOWNTO 74);
    EX_MEM_REG : RegisterDFF GENERIC MAP(72) PORT MAP(clk, reset, '1', EX_MEM_IN, EX_MEM_OUT);
    MAIN_MEMORY : RAM PORT MAP(clk, reset, EX_MEM_OUT(69), EX_MEM_OUT(66 DOWNTO 35), EX_MEM_OUT(34 DOWNTO 3), MEM_OUT); -- TODO: ADD RESET PC output
    -- WB stage
    MEM_WB_IN <= EX_MEM_OUT(68) & EX_MEM_OUT(67) & MEM_OUT & EX_MEM_OUT(66 DOWNTO 35) & EX_MEM_OUT(2 DOWNTO 0);
    MEM_WB_REG : RegisterDFF GENERIC MAP(69) PORT MAP(clk, reset, '1', MEM_WB_IN, MEM_WB_OUT);
    OUTP <= MEM_WB_OUT(34 DOWNTO 3);

END ARCHITECTURE;