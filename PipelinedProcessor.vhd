LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PipelinedProcessor IS
    GENERIC (
        n : INTEGER := 32);
    PORT (
        clk, reset : IN STD_LOGIC;
        INP : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
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
    COMPONENT RegisterPC IS
        GENERIC (n : INTEGER := 32);
        PORT (
            clk, reset, enable : IN STD_LOGIC;
            memoryOfZero : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;
    --
    COMPONENT RegisterSP IS
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
            WB_MemToReg : OUT STD_LOGIC;
            IN_PORT_INSTR : OUT STD_LOGIC;
            OUT_PORT_INSTR : OUT STD_LOGIC;
            ADD2_OR_SUB2_Stack : OUT STD_LOGIC;
            CALL_INST : OUT STD_LOGIC
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
            --To read and write two consecuetive places at a time
            datain : IN STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0);
            dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0));
    END COMPONENT;
    --
    COMPONENT ROM IS
        GENERIC (
            STORED_DATA_SIZE : INTEGER := 16;
            ADRESS_SIZE : INTEGER := 20;
            ROM_SIZE : INTEGER := 2 ** 20);
        PORT (
            address : IN STD_LOGIC_VECTOR(ADRESS_SIZE - 1 DOWNTO 0);
            --To read and write two consecuetive places at a time
            dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0);
            memoryOfZeroForPCReset : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE - 1 DOWNTO 0));
    END COMPONENT;
    ---------------> End of Components <--------------
    ---------------> Start of Signals <--------------
    ---------------> Fetch Signals <--------------
    -- SIGNAL INSTRUCTION : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL IF_ID_IN : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL IF_ID_OUT : STD_LOGIC_VECTOR(2 * n - 1 DOWNTO 0);
    --(63 DOWNTO 32) INPUT_PORT
    --(31 DOWNTO 0) INSTRUCTION
    SIGNAL INSTRUCTION : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL PC_IN : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);

    ---------------> Decode Signals <--------------
    SIGNAL DECODEOUT1 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL DECODEOUT2 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    ---------------> Execute Signals <--------------
    SIGNAL ID_EX_IN : STD_LOGIC_VECTOR(139 - 1 DOWNTO 0);
    SIGNAL ID_EX_OUT : STD_LOGIC_VECTOR(139 - 1 DOWNTO 0);
    --(138 DOWNTO 107)INPUT_PORT
    --(106 DOWNTO 106) IS_CALL
    --(105 DOWNTO 105) IS_ADD2_OR_SUB2_STACK
    --(104 DOWNTO 104) IS_IN
    --(103 DOWNTO 101)OP2
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
    SIGNAL EX_MEM_IN : STD_LOGIC_VECTOR(110 - 1 DOWNTO 0);
    SIGNAL EX_MEM_OUT : STD_LOGIC_VECTOR(110 - 1 DOWNTO 0);
    --(109 DOWNTO 78) INPUT_PORT
    --(77 DOWNTO 77) IS_CALL
    --(76 DOWNTO 76) IS_ADD2_OR_SUB2_STACK
    --(75 DOWNTO 75) IS_IN
    --(74 DOWNTO 72)OP2
    --(71 DOWNTO 71)UseStack 
    --(70 DOWNTO 70)MemRead 
    --(69 DOWNTO 69)MemWrite 
    --(68 DOWNTO 68)WBEnable 
    --(67 DOWNTO 67)MemToReg  
    --(66 DOWNTO 35)ALU OUT
    --(34 DOWNTO 3)OP2 VALUE
    --(2 DOWNTO 0)OP1 
    SIGNAL MEM_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL MEMORY_ADDRESS : STD_LOGIC_VECTOR(20 - 1 DOWNTO 0);
    ---------------> Write back Signals <--------------
    SIGNAL MEM_WB_IN : STD_LOGIC_VECTOR(105 - 1 DOWNTO 0);
    SIGNAL MEM_WB_OUT : STD_LOGIC_VECTOR(105 - 1 DOWNTO 0);
    --(104 DOWNTO 73) INPUT_PORT
    --(72 DOWNTO 72) IS_IN
    --(71 DOWNTO 69)OP2
    --(68 DOWNTO 68)WBEnable 
    --(67 DOWNTO 67)MemToReg  
    --(66 DOWNTO 35) MEMORY_OUT
    --(34 DOWNTO 3) ALU_OUT
    --(2 DOWNTO 0) OP1 ADRESS TODO: I think this should be OP2 address if the instruction is LOAD
    ---------------> Control Signals <--------------
    SIGNAL CNT_SRC_IS_IMM : STD_LOGIC;
    SIGNAL CNT_IS_ALU_OPERATION : STD_LOGIC;
    SIGNAL CNT_IS_MEM_WRITE : STD_LOGIC;
    SIGNAL CNT_IS_MEM_READ : STD_LOGIC;
    SIGNAL CNT_IS_STACK : STD_LOGIC;
    SIGNAL CNT_WB_IS_ON : STD_LOGIC;
    SIGNAL CNT_WB_TO_MEM : STD_LOGIC;
    SIGNAL CNT_IS_IN : STD_LOGIC;
    SIGNAL CNT_IS_OUT : STD_LOGIC;
    SIGNAL CNT_IS_ADD2_OR_SUB2_STACK : STD_LOGIC;
    SIGNAL CNT_IS_CALL_INST : STD_LOGIC;
    ---------------> Signals use Control Selectors <--------------
    SIGNAL WRTIE_TO_REG : STD_LOGIC;
    SIGNAL OPERAND2 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    ---------------> Signals EXTRA<--------------
    SIGNAL memoryOfZeroForPCReset : STD_LOGIC_VECTOR(16 - 1 DOWNTO 0);
    SIGNAL ValueToWriteBackToReg : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL adressToWriteBackToReg : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0);
    SIGNAL SP_IN, SP_IN_temp, SP_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    ---------------> End of Signals <--------------
BEGIN
    -- Fetching stage

    --PC Register
    PC_REG : RegisterPC GENERIC MAP(n) PORT MAP(clk, reset, '1', memoryOfZeroForPCReset, PC_IN, PC_OUT); --TODO: in case we are gonna implement the branch instructions, the write enable won't always be 1.
    --Fetch the instruction from the ROM
    INSTRUCTIONS_MEMORY : ROM PORT MAP(PC_OUT(19 DOWNTO 0), IF_ID_IN, memoryOfZeroForPCReset);
    --IF_ID Buffer
    IF_ID_REG : RegisterDFF GENERIC MAP(2 * n) PORT MAP(clk, reset, '1', INP & IF_ID_IN, IF_ID_OUT);
    INSTRUCTION <= IF_ID_OUT(31 DOWNTO 0);
    --Increment the PC by 1 if it's a 16-bit instruction and 2 if it's a 32-bit instruction.
    --TODO: More cases will have to be handled if we are gonna implement the branch instructions.
    PC_IN <= STD_LOGIC_VECTOR(unsigned(PC_OUT) + 1)
        WHEN IF_ID_IN(30) = '0'
        ELSE
        STD_LOGIC_VECTOR(unsigned(PC_OUT) + 2);

    -- Decoding stage
    REG_READ_WRITE : Registers PORT MAP(clk, reset, WRTIE_TO_REG, INSTRUCTION(26 DOWNTO 24), INSTRUCTION(23 DOWNTO 21), adressToWriteBackToReg, ValueToWriteBackToReg, DECODEOUT1, DECODEOUT2);
    CONTROL_UNIT : ControlUnit PORT MAP(INSTRUCTION, '0', CNT_SRC_IS_IMM, CNT_IS_ALU_OPERATION, CNT_IS_MEM_WRITE, CNT_IS_MEM_READ, CNT_IS_STACK, CNT_WB_IS_ON, CNT_WB_TO_MEM, CNT_IS_IN, CNT_IS_OUT, CNT_IS_ADD2_OR_SUB2_STACK, CNT_IS_CALL_INST); -- TODO: Replace '0' with stall flag
    OUTP <= DECODEOUT1 -- OUTPORT
        WHEN
        CNT_IS_OUT = '1'
        ELSE
        (OTHERS => 'X');
    -- Execute Stage
    ID_EX_IN <= IF_ID_OUT(63 DOWNTO 32) & CNT_IS_CALL_INST & CNT_IS_ADD2_OR_SUB2_STACK & CNT_IS_IN & INSTRUCTION(23 DOWNTO 21) & CNT_IS_ALU_OPERATION & CNT_SRC_IS_IMM & CNT_IS_ALU_OPERATION & CNT_IS_STACK & CNT_IS_MEM_READ & CNT_IS_MEM_WRITE & CNT_WB_IS_ON & CNT_WB_TO_MEM & INSTRUCTION(20 DOWNTO 5) & INSTRUCTION(26 DOWNTO 24) & INSTRUCTION(31 DOWNTO 27) & INSTRUCTION(20 DOWNTO 16) & DECODEOUT2 & DECODEOUT1;
    ID_EX_REG : RegisterDFF GENERIC MAP(139) PORT MAP(clk, reset, '1', ID_EX_IN, ID_EX_OUT);
    OPERAND2 <= (31 DOWNTO 16 => ID_EX_OUT(92)) & ID_EX_OUT(92 DOWNTO 77) -- Immediate with Sign extend
        WHEN
        ID_EX_OUT(99) = '1'
        ELSE
        ID_EX_OUT(63 DOWNTO 32);
    ALU_MODULE : ALU PORT MAP(ID_EX_OUT(31 DOWNTO 0), OPERAND2, ID_EX_OUT(73 DOWNTO 69), ID_EX_OUT(68 DOWNTO 64), ALU_OUT, ALU_FLAGS_OUT);
    -- Memory Stage
    EX_MEM_IN <= ID_EX_OUT(138 DOWNTO 107) & ID_EX_OUT(106) & ID_EX_OUT(105) & ID_EX_OUT(104) & ID_EX_OUT(103 DOWNTO 101) & ID_EX_OUT(97) & ID_EX_OUT(96) & ID_EX_OUT(95) & ID_EX_OUT(94) & ID_EX_OUT(93) & ALU_OUT & ID_EX_OUT(63 DOWNTO 32) & ID_EX_OUT(76 DOWNTO 74);
    EX_MEM_REG : RegisterDFF GENERIC MAP(110) PORT MAP(clk, reset, '1', EX_MEM_IN, EX_MEM_OUT);
    MAIN_MEMORY : RAM PORT MAP(clk, reset, EX_MEM_OUT(69), MEMORY_ADDRESS, EX_MEM_OUT(34 DOWNTO 3), MEM_OUT);

    --Check whether to take the memory address of the ALU or SP
    MEMORY_ADDRESS <= EX_MEM_OUT(54 DOWNTO 35)
        WHEN EX_MEM_OUT(71) = '0'
        ELSE
        SP_OUT(19 DOWNTO 0);

    --Things related to the stack register
    SP_REG : RegisterSP GENERIC MAP(32) PORT MAP(clk, reset, EX_MEM_OUT(71), SP_IN, SP_OUT);
    SP_IN_temp <= STD_LOGIC_VECTOR(unsigned(SP_OUT) + 2)
        WHEN EX_MEM_OUT(76) = '0'
        ELSE
        STD_LOGIC_VECTOR(unsigned(SP_OUT) - 2);
    SP_IN <= SP_IN_temp WHEN EX_MEM_OUT(71) = '1'
        ELSE
        SP_OUT;

    -- WB stage
    MEM_WB_IN <= EX_MEM_OUT(109 DOWNTO 78) & EX_MEM_OUT(75) & EX_MEM_OUT(74 DOWNTO 72) & EX_MEM_OUT(68) & EX_MEM_OUT(67) & MEM_OUT & EX_MEM_OUT(66 DOWNTO 35) & EX_MEM_OUT(2 DOWNTO 0);
    MEM_WB_REG : RegisterDFF GENERIC MAP(105) PORT MAP(clk, reset, '1', MEM_WB_IN, MEM_WB_OUT);
    ValueToWriteBackToReg <= MEM_WB_OUT(34 DOWNTO 3)
        WHEN
        MEM_WB_OUT(67) = '0' AND MEM_WB_OUT(72) = '0'
        ELSE
        MEM_WB_OUT(104 DOWNTO 73) --INPUT PORT
        WHEN
        MEM_WB_OUT(67) = '0' AND MEM_WB_OUT(72) = '1'
        ELSE
        MEM_WB_OUT(66 DOWNTO 35);
    adressToWriteBackToReg <= MEM_WB_OUT(71 DOWNTO 69)
        WHEN
        MEM_WB_OUT(67) = '1'
        ELSE
        MEM_WB_OUT(2 DOWNTO 0);
    WRTIE_TO_REG <= '1'
        WHEN
        MEM_WB_OUT(68) = '1'
        ELSE
        '0';
END ARCHITECTURE;