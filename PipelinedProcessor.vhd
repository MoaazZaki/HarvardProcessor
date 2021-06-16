LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY PipelinedProcessor IS
    GENERIC (
        n : INTEGER := 32);
    PORT (
        clk, reset : IN STD_LOGIC := '1';
        INP : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
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
    COMPONENT FlagsRegister IS
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
            CALL_INST : OUT STD_LOGIC;
            RET_INST : OUT STD_LOGIC;
            IS_LOAD : OUT STD_LOGIC
        );
    END COMPONENT;
    --
    COMPONENT JumpControl IS
        GENERIC (N : INTEGER := 5);
        PORT (
            operation : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            flags : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            branchTaken : OUT STD_LOGIC
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
            sp_address : IN STD_LOGIC_VECTOR(ADRESS_SIZE - 1 DOWNTO 0);
            --To read and write two consecuetive places at a time
            datain : IN STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0);
            dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0);
            sp_dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0));
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

    COMPONENT ForwardingUnit IS
        GENERIC (REGS_INDEX_SIZE : INTEGER := 3); --3 bits to choose from 8 registers
        PORT (
            EX_MEM_WillIWriteBack, MEM_WB_WillIWriteBack : IN STD_LOGIC;
            ID_EX_Operand1, ID_EX_Operand2 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0);
            EX_MEM_Operand1, MEM_WB_Operand1 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0);
            SEL_MUX_Operand1, SEL_MUX_Operand2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));

        -- *****SEL_MUX_Operand1***** --
        -- 00-->EX_MEM_WillIWriteBack AND ID_EX_Operand1==EX_MEM_Operand1 (ALU-ALU FORWARDIND)
        -- 01-->MEM_WB_WillIWriteBack AND ID_EX_Operand1==MEM_WB_Operand1 (MEM-ALU FORWARDIND)
        -- 1x--> ELSE NO FORWARDIND

        -- *****SEL_MUX_Operand2***** --
        -- 00-->EX_MEM_WillIWriteBack AND ID_EX_Operand2==EX_MEM_Operand1 (ALU-ALU FORWARDIND)
        -- 01-->MEM_WB_WillIWriteBack AND ID_EX_Operand2==MEM_WB_Operand1 (MEM-ALU FORWARDIND)
        -- 1x--> ELSE NO FORWARDIND

    END COMPONENT;
    --
    COMPONENT HazardDetectionUnit IS
        GENERIC (REG_SIZE : INTEGER := 3);
        PORT (
            BT, MEM : IN STD_LOGIC;
            OP1 : IN STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
            OP2 : IN STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
            LOAD_OP : IN STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
            OUT1, OUT2, OUT3 : OUT STD_LOGIC
        );
    END COMPONENT;
    ---------------> End of Components <--------------
    ---------------> Start of Signals <--------------
    ---------------> Fetch Signals <--------------
    -- SIGNAL INSTRUCTION : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL FETCHED_INSTRUCTION : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IF_ID_IN : STD_LOGIC_VECTOR(2 * n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IF_ID_OUT : STD_LOGIC_VECTOR(2 * n - 1 DOWNTO 0) := (OTHERS => '0');
    --(63 DOWNTO 32) INPUT_PORT
    --(31 DOWNTO 0) INSTRUCTION
    SIGNAL INSTRUCTION : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_IN_temp : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_IN : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_PLUS_TWO : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL PC_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');

    ---------------> Decode Signals <--------------
    SIGNAL DECODEOUT1 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL DECODEOUT2 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------> Branching Signals <--------------
    SIGNAL BRANCHTAKEN : STD_LOGIC := '0';
    ---------------> Execute Signals <--------------
    SIGNAL ID_EX_IN : STD_LOGIC_VECTOR(142 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ID_EX_OUT : STD_LOGIC_VECTOR(142 - 1 DOWNTO 0) := (OTHERS => '0');
    --(141 DOWNTO 141) IS_LOAD
    --(140 DOWNTO 140) IS_OUT
    --(139 DOWNTO 139)BRANCHTAKEN
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
    SIGNAL ALU_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALU_FLAGS_OUT : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ALU_FLAGS_STORED : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
    -- (0) ZERO_FLAG
    -- (1) NEGATIVE_FLAG
    -- (2) CARRY_FLAG
    ---------------> Memory Signals <--------------
    SIGNAL EX_MEM_IN : STD_LOGIC_VECTOR(142 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL EX_MEM_OUT : STD_LOGIC_VECTOR(142 - 1 DOWNTO 0) := (OTHERS => '0');
    --(141 DOWNTO 110)OP1 VALUE
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
    SIGNAL MEM_OUT : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEMORY_VALUE_TO_WRITE : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEMORY_ADDRESS : STD_LOGIC_VECTOR(20 - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------> Write back Signals <--------------
    SIGNAL MEM_WB_IN : STD_LOGIC_VECTOR(106 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL MEM_WB_OUT : STD_LOGIC_VECTOR(106 - 1 DOWNTO 0) := (OTHERS => '0');
    --(105 DOWNTO 105)UseStack 
    --(104 DOWNTO 73) INPUT_PORT
    --(72 DOWNTO 72) IS_IN
    --(71 DOWNTO 69)OP2
    --(68 DOWNTO 68)WBEnable 
    --(67 DOWNTO 67)MemToReg  
    --(66 DOWNTO 35) MEMORY_OUT
    --(34 DOWNTO 3) ALU_OUT
    --(2 DOWNTO 0) OP1 ADRESS TODO: I think this should be OP2 address if the instruction is LOAD
    ---------------> Control Signals <--------------
    SIGNAL CNT_SRC_IS_IMM : STD_LOGIC := '0';
    SIGNAL CNT_IS_ALU_OPERATION : STD_LOGIC := '0';
    SIGNAL CNT_IS_MEM_WRITE : STD_LOGIC := '0';
    SIGNAL CNT_IS_MEM_READ : STD_LOGIC := '0';
    SIGNAL CNT_IS_STACK : STD_LOGIC := '0';
    SIGNAL CNT_WB_IS_ON : STD_LOGIC := '0';
    SIGNAL CNT_WB_TO_MEM : STD_LOGIC := '0';
    SIGNAL CNT_IS_IN : STD_LOGIC := '0';
    SIGNAL CNT_IS_OUT : STD_LOGIC := '0';
    SIGNAL CNT_IS_ADD2_OR_SUB2_STACK : STD_LOGIC := '0';
    SIGNAL CNT_IS_CALL_INST : STD_LOGIC := '0';
    SIGNAL CNT_IS_RET_INST : STD_LOGIC := '0';
    SIGNAL CNT_IS_LOAD : STD_LOGIC := '0';
    ---------------> Hazard Signals <--------------
    SIGNAL HZD_CHANGE_PC : STD_LOGIC := '0';
    SIGNAL HZD_CHANGE_IF_ID_BUFFER : STD_LOGIC := '0';
    SIGNAL HZD_STALL : STD_LOGIC := '0';

    SIGNAL PC_ENABLE : STD_LOGIC := '0';
    SIGNAL IF_ID_ENABLE : STD_LOGIC := '0';
    ---------------> Signals use Control Selectors <--------------
    SIGNAL WRTIE_TO_REG : STD_LOGIC := '0';
    SIGNAL OPERAND2 : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------> EXTRA Signals<--------------
    SIGNAL memoryOfZeroForPCReset : STD_LOGIC_VECTOR(16 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ValueToWriteBackToReg_MEM_WB : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL ValueToWriteBackToReg_EX_MEM : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL adressToWriteBackToReg_MEM_WB : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL adressToWriteBackToReg_EX_MEM : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SP_IN, SP_IN_temp, SP_IN_temp2, SP_OUT, SP_DATA : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SP_ADDRESS : STD_LOGIC_VECTOR(19 DOWNTO 0) := (OTHERS => '0');
    SIGNAL POP_OR_LOAD_ADDRESS : STD_LOGIC_VECTOR(3 - 1 DOWNTO 0) := (OTHERS => '0');
    ---------------> Forwarding Signals <--------------
    SIGNAL SEL_MUX_Operand1, SEL_MUX_Operand2 : STD_LOGIC_VECTOR(1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OPERAND1_AFTER_FORWARDING : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL OPERAND2_AFTER_FORWARDING : STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');

    ---------------> End of Signals <--------------
BEGIN
    -- Fetching stage

    --PC Register
    PC_ENABLE <= '0'
        WHEN
        HZD_CHANGE_PC = '0'
        ELSE
        '1';
    PC_REG : RegisterPC GENERIC MAP(n) PORT MAP(clk, reset, PC_ENABLE, memoryOfZeroForPCReset, PC_IN, PC_OUT); --TODO: in case we are gonna implement the branch instructions, the write enable won't always be 1.
    --Fetch the instruction from the ROM
    INSTRUCTIONS_MEMORY : ROM PORT MAP(PC_OUT(19 DOWNTO 0), FETCHED_INSTRUCTION, memoryOfZeroForPCReset);
    --IF_ID Buffer
    IF_ID_IN <= INP & FETCHED_INSTRUCTION;
    IF_ID_ENABLE <= '0'
        WHEN
        HZD_CHANGE_IF_ID_BUFFER = '0'
        ELSE
        '1';
    IF_ID_REG : RegisterDFF GENERIC MAP(64) PORT MAP(clk, reset, IF_ID_ENABLE, IF_ID_IN, IF_ID_OUT);
    INSTRUCTION <= IF_ID_OUT(31 DOWNTO 0);
    --Increment the PC by 1 if it's a 16-bit instruction and 2 if it's a 32-bit instruction.
    --TODO: More cases will have to be handled if we are gonna implement the branch instructions.
    PC_IN_temp <= STD_LOGIC_VECTOR(unsigned(PC_OUT) + 1) WHEN FETCHED_INSTRUCTION(30) = '0' AND BRANCHTAKEN = '0'
        ELSE
        STD_LOGIC_VECTOR(unsigned(PC_OUT) + 2) WHEN FETCHED_INSTRUCTION(30) = '1' AND BRANCHTAKEN = '0'
        ELSE
        DECODEOUT1 WHEN BRANCHTAKEN = '1';

    PC_IN <= PC_IN_temp WHEN CNT_IS_RET_INST = '0'
        ELSE
        SP_DATA;

    -- Decoding stage

    --Handling stalling
    POP_OR_LOAD_ADDRESS <= ID_EX_OUT(103 DOWNTO 101)
        WHEN ID_EX_OUT(141) = '1' --is load instruction 
        ELSE --the instruction is pop
        ID_EX_OUT(76 DOWNTO 74);
    REG_READ_WRITE : Registers PORT MAP(clk, reset, WRTIE_TO_REG, INSTRUCTION(26 DOWNTO 24), INSTRUCTION(23 DOWNTO 21), adressToWriteBackToReg_MEM_WB, ValueToWriteBackToReg_MEM_WB, DECODEOUT1, DECODEOUT2);
    HAZARD_DETECTION_UNIT : HazardDetectionUnit PORT MAP(ID_EX_OUT(139), ID_EX_OUT(96), INSTRUCTION(26 DOWNTO 24), INSTRUCTION(23 DOWNTO 21), POP_OR_LOAD_ADDRESS, HZD_CHANGE_IF_ID_BUFFER, HZD_CHANGE_PC, HZD_STALL);
    CONTROL_UNIT : ControlUnit PORT MAP(INSTRUCTION, HZD_STALL, CNT_SRC_IS_IMM, CNT_IS_ALU_OPERATION, CNT_IS_MEM_WRITE, CNT_IS_MEM_READ, CNT_IS_STACK, CNT_WB_IS_ON, CNT_WB_TO_MEM, CNT_IS_IN, CNT_IS_OUT, CNT_IS_ADD2_OR_SUB2_STACK, CNT_IS_CALL_INST, CNT_IS_RET_INST, CNT_IS_LOAD); -- TODO: Replace '0' with stall flag

    --Branching part
    JUMP_CONTOL : JumpControl GENERIC MAP(5) PORT MAP(INSTRUCTION(31 DOWNTO 27), ALU_FLAGS_STORED, BRANCHTAKEN);

    -- Execute Stage
    ID_EX_IN <= CNT_IS_LOAD & CNT_IS_OUT & BRANCHTAKEN & IF_ID_OUT(63 DOWNTO 32) & CNT_IS_CALL_INST & CNT_IS_ADD2_OR_SUB2_STACK & CNT_IS_IN & INSTRUCTION(23 DOWNTO 21) & CNT_IS_ALU_OPERATION & CNT_SRC_IS_IMM & CNT_IS_ALU_OPERATION & CNT_IS_STACK & CNT_IS_MEM_READ & CNT_IS_MEM_WRITE & CNT_WB_IS_ON & CNT_WB_TO_MEM & INSTRUCTION(20 DOWNTO 5) & INSTRUCTION(26 DOWNTO 24) & INSTRUCTION(31 DOWNTO 27) & INSTRUCTION(20 DOWNTO 16) & DECODEOUT2 & DECODEOUT1;
    ID_EX_REG : RegisterDFF GENERIC MAP(142) PORT MAP(clk, reset, '1', ID_EX_IN, ID_EX_OUT);
    --Handling RAW Data dependancy by adding a forward unit
    --Forwarding unit-------------------->   WB_EnableExcute, WB_EnableMEM,   op1_addressID_EX,        op2_addressID_EX           EX_MEM_Operand1                MEM_WB_Operand1
    FULL_FORWARDING : ForwardingUnit PORT MAP(EX_MEM_OUT(68), MEM_WB_OUT(68), ID_EX_OUT(76 DOWNTO 74), ID_EX_OUT(103 DOWNTO 101), adressToWriteBackToReg_EX_MEM, adressToWriteBackToReg_MEM_WB, SEL_MUX_Operand1, SEL_MUX_Operand2);
    --Choosing whether to forward or take the output of the decode stage
    OPERAND1_AFTER_FORWARDING <= ValueToWriteBackToReg_EX_MEM --ALU-ALU Forwarding
        WHEN SEL_MUX_Operand1 = "00"
        ELSE
        ValueToWriteBackToReg_MEM_WB --MEM-ALU Forwarding
        WHEN SEL_MUX_Operand1 = "01"
        ELSE
        ID_EX_OUT(31 DOWNTO 0); --NO Forwarding

    OPERAND2 <= ValueToWriteBackToReg_EX_MEM --ALU-ALU Forwarding
        WHEN SEL_MUX_Operand2 = "00"
        ELSE
        ValueToWriteBackToReg_MEM_WB --MEM-ALU Forwarding
        WHEN SEL_MUX_Operand2 = "01"
        ELSE
        ID_EX_OUT(63 DOWNTO 32); --NO Forwarding

    OPERAND2_AFTER_FORWARDING <= (31 DOWNTO 16 => '0') & ID_EX_OUT(92 DOWNTO 77) -- Immediate with Sign extend
        WHEN
        ID_EX_OUT(99) = '1'
        ELSE
        OPERAND2;

    ALU_MODULE : ALU PORT MAP(OPERAND1_AFTER_FORWARDING, OPERAND2_AFTER_FORWARDING, ID_EX_OUT(73 DOWNTO 69), ID_EX_OUT(68 DOWNTO 64), ALU_OUT, ALU_FLAGS_OUT);
    FLAGS_REG : FlagsRegister GENERIC MAP(3) PORT MAP(clk, reset, ID_EX_OUT(98), ALU_FLAGS_OUT, ALU_FLAGS_STORED);
    --handling output port in the execute stage
    OUTP <= OPERAND1_AFTER_FORWARDING -- OUTPORT
        WHEN
        ID_EX_OUT(140) = '1'
        ELSE
        (OTHERS => 'X');

    -- Memory Stage
    SP_ADDRESS <= STD_LOGIC_VECTOR(unsigned(SP_OUT(19 DOWNTO 0)) + 2);
    EX_MEM_IN <= OPERAND1_AFTER_FORWARDING & ID_EX_OUT(138 DOWNTO 107) & ID_EX_OUT(106) & ID_EX_OUT(105) & ID_EX_OUT(104) & ID_EX_OUT(103 DOWNTO 101) & ID_EX_OUT(97) & ID_EX_OUT(96) & ID_EX_OUT(95) & ID_EX_OUT(94) & ID_EX_OUT(93) & ALU_OUT & OPERAND2 & ID_EX_OUT(76 DOWNTO 74);
    EX_MEM_REG : RegisterDFF GENERIC MAP(142) PORT MAP(clk, reset, '1', EX_MEM_IN, EX_MEM_OUT);
    MAIN_MEMORY : RAM PORT MAP(clk, reset, EX_MEM_OUT(69), MEMORY_ADDRESS, SP_ADDRESS, MEMORY_VALUE_TO_WRITE, MEM_OUT, SP_DATA);

    --Check whether to take the memory address of the ALU or SP
    MEMORY_ADDRESS <= EX_MEM_OUT(54 DOWNTO 35)
        WHEN EX_MEM_OUT(71) = '0'
        ELSE
        SP_OUT(19 DOWNTO 0)
        WHEN EX_MEM_OUT(76) = '1'
        ELSE
        STD_LOGIC_VECTOR(unsigned(SP_OUT(19 DOWNTO 0)) + 2);

    MEMORY_VALUE_TO_WRITE <= EX_MEM_OUT(141 DOWNTO 110)
        WHEN
        EX_MEM_OUT(71) = '1' --take the first operand if useStack(push) and second operand otherwise
        ELSE
        EX_MEM_OUT(34 DOWNTO 3);

    --Things related to the stack register
    SP_REG : RegisterSP GENERIC MAP(32) PORT MAP(clk, reset, EX_MEM_OUT(71), SP_IN, SP_OUT);

    SP_IN_temp <= STD_LOGIC_VECTOR(unsigned(SP_OUT) + 2)
        WHEN EX_MEM_OUT(76) = '0'
        ELSE
        STD_LOGIC_VECTOR(unsigned(SP_OUT) - 2);

    SP_IN_temp2 <= SP_IN_temp WHEN EX_MEM_OUT(71) = '1'
        -- AND EX_MEM_OUT(76) = '1'
        ELSE
        SP_OUT;

    PC_PLUS_TWO <= STD_LOGIC_VECTOR(unsigned(PC_OUT) + 2);

    SP_IN <= SP_IN_temp2 WHEN EX_MEM_OUT(77) = '0'
        ELSE
        PC_PLUS_TWO;

    ValueToWriteBackToReg_EX_MEM <= EX_MEM_OUT(109 DOWNTO 78) --INPUT PORT
        WHEN
        EX_MEM_OUT(75) = '1' -- "in" inst
        ELSE
        EX_MEM_OUT(66 DOWNTO 35); --ALU output

    adressToWriteBackToReg_EX_MEM <= EX_MEM_OUT(74 DOWNTO 72) --take op2 address
        WHEN
        EX_MEM_OUT(67) = '1' AND EX_MEM_OUT(71) = '0' --in case it's a memory inst. and not push,pop,call,ret
        ELSE
        EX_MEM_OUT(2 DOWNTO 0);--take op1 address otherwise

    -- WB stage
    MEM_WB_IN <= EX_MEM_OUT(71) & EX_MEM_OUT(109 DOWNTO 78) & EX_MEM_OUT(75) & EX_MEM_OUT(74 DOWNTO 72) & EX_MEM_OUT(68) & EX_MEM_OUT(67) & MEM_OUT & EX_MEM_OUT(66 DOWNTO 35) & EX_MEM_OUT(2 DOWNTO 0);
    MEM_WB_REG : RegisterDFF GENERIC MAP(106) PORT MAP(clk, reset, '1', MEM_WB_IN, MEM_WB_OUT);

    ValueToWriteBackToReg_MEM_WB <= MEM_WB_OUT(34 DOWNTO 3)
        WHEN
        MEM_WB_OUT(67) = '0' AND MEM_WB_OUT(72) = '0'
        ELSE
        MEM_WB_OUT(104 DOWNTO 73) --INPUT PORT
        WHEN
        MEM_WB_OUT(67) = '0' AND MEM_WB_OUT(72) = '1'
        ELSE
        MEM_WB_OUT(66 DOWNTO 35);

    adressToWriteBackToReg_MEM_WB <= MEM_WB_OUT(71 DOWNTO 69) --take op2 address
        WHEN
        MEM_WB_OUT(67) = '1' AND MEM_WB_OUT(105) = '0' --in case it's a memory inst. and not push,pop,call,ret
        ELSE
        MEM_WB_OUT(2 DOWNTO 0);--take op1 address otherwise

    WRTIE_TO_REG <= '1'
        WHEN
        MEM_WB_OUT(68) = '1'
        ELSE
        '0';
END ARCHITECTURE;