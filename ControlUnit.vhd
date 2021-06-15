LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ControlUnit IS
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
        RET_INST : OUT STD_LOGIC
    );
END ControlUnit;

ARCHITECTURE rtl OF ControlUnit IS
    SIGNAL ALU_Operation_temp, MEM_Write_temp, MEM_Read_temp, MEM_useStack_temp, WB_WBEnable_temp, IN_PORT_INSTR_temp, OUT_PORT_INSTR_temp, CALL_INST_temp, RET_INST_temp : STD_LOGIC;
BEGIN
    ALU_Src_ImmOrReg <= '0' WHEN (instruction(31 DOWNTO 30) = "00")
        ELSE
        '1'; --1--> take Immediate, 0--> take operand 2

    ALU_Operation_temp <= '1' WHEN (instruction(31 DOWNTO 30) = "00") OR (instruction(29 DOWNTO 28) = "11")
        ELSE
        '0'; --1--> If it is ALU or It's LDM or IADD, 0--> otherwise

    --TODO: add branch (call, return ) to write_me, read_mem
    MEM_Write_temp <= '1' WHEN (instruction(31 DOWNTO 27) = "01000") OR (instruction(31 DOWNTO 27) = "01010")
        ELSE
        '0'; --I will write to the memory if the instruction is Store or Push

    MEM_Read_temp <= '1' WHEN (instruction(31 DOWNTO 27) = "01001") OR (instruction(31 DOWNTO 27) = "01011")
        ELSE
        '0'; --I will read from the memory if the instruction is Load or Pop

    MEM_useStack_temp <= '1' WHEN (instruction(31 DOWNTO 27) = "01000")
        OR (instruction(31 DOWNTO 27) = "01001")
        OR (instruction(31 DOWNTO 27) = "10100")
        OR (instruction(31 DOWNTO 27) = "10101")
        ELSE
        '0'; --I will use the stack if I am Push, Pop, Call, or Return
    --Here using the stack means using sp to access a memory location instead of using the ALU output 

    WB_WBEnable_temp <= '1' WHEN ((instruction(31 DOWNTO 27) = "00000")
        AND (NOT (instruction(20 DOWNTO 16) = "00000"))
        AND (NOT (instruction(20 DOWNTO 16) = "00001"))
        AND (NOT (instruction(20 DOWNTO 16) = "00010"))
        AND (NOT (instruction(20 DOWNTO 16) = "00110")))
        OR ((instruction(31 DOWNTO 30) = "00") AND (NOT(instruction(31 DOWNTO 27) = "00000")))
        OR ((instruction(31 DOWNTO 30) = "01")
        AND (NOT(instruction(31 DOWNTO 27) = "01000"))
        AND (NOT(instruction(31 DOWNTO 27) = "01010")))
        ELSE --I will Write back if I am ALU, but I am not (NOP,SETC,CLRC,OUT)
        '0'; --OR if I am memory, but I am not (Push,Store)

    WB_MemToReg <= '1' WHEN (instruction(31 DOWNTO 27) = "01001") OR (instruction(31 DOWNTO 27) = "01011")
        ELSE --Whether I will write back the output of the ALU or the output of the memory
        '0'; --The only 2 cases I will write back the output of the memory -->(Pop, Load)

    IN_PORT_INSTR_temp <= '1' WHEN (instruction(31 DOWNTO 27) = "00000") AND (instruction(20 DOWNTO 16) = "00111")
        ELSE
        '0';

    OUT_PORT_INSTR_temp <= '1' WHEN (instruction(31 DOWNTO 27) = "00000") AND (instruction(20 DOWNTO 16) = "00110")
        ELSE
        '0';

    ADD2_OR_SUB2_Stack <= '0' WHEN (instruction(31 DOWNTO 27) = "01001") OR (instruction(31 DOWNTO 27) = "10101")
        ELSE
        '1';--0--> ADD 2 to the SP (Pop, return),  1-->SUB 2 to the SP (Push, call)

    CALL_INST_temp <= '1' WHEN (instruction(31 DOWNTO 27) = "10100")
        ELSE
        '0';--'1' if it's a call instruction and zero otherwise

    RET_INST_temp <= '1' WHEN (instruction(31 DOWNTO 27) = "10101")
        ELSE
        '0';--'1' if it's a ret instruction and zero otherwise

    -------------------Stalling Conditions---------------------------
    ALU_Operation <= ALU_Operation_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    MEM_Write <= MEM_Write_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    MEM_Read <= MEM_Read_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    MEM_useStack <= MEM_useStack_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    WB_WBEnable <= WB_WBEnable_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    IN_PORT_INSTR <= IN_PORT_INSTR_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    OUT_PORT_INSTR <= OUT_PORT_INSTR_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    CALL_INST <= CALL_INST_temp WHEN (IshouldStall = '0')
        ELSE
        '0';

    RET_INST <= RET_INST_temp WHEN (IshouldStall = '0')
    ELSE
    '0';

END ARCHITECTURE;