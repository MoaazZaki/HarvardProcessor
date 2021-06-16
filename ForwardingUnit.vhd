LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ForwardingUnit IS
    GENERIC (REGS_INDEX_SIZE : INTEGER := 3); --3 bits to choose from 8 registers
    PORT (
        EX_MEM_WillIWriteBack, MEM_WB_WillIWriteBack : IN STD_LOGIC :='0';
        ID_EX_Operand1, ID_EX_Operand2 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
        EX_MEM_Operand1, MEM_WB_Operand1 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
        SEL_MUX_Operand1, SEL_MUX_Operand2 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));

    -- *****SEL_MUX_Operand1***** --
    -- 00-->EX_MEM_WillIWriteBack AND ID_EX_Operand1==EX_MEM_Operand1 (ALU-ALU FORWARDIND)
    -- 01-->MEM_WB_WillIWriteBack AND ID_EX_Operand1==MEM_WB_Operand1 (MEM-ALU FORWARDIND)
    -- 1x--> ELSE NO FORWARDIND

    -- *****SEL_MUX_Operand2***** --
    -- 00-->EX_MEM_WillIWriteBack AND ID_EX_Operand2==EX_MEM_Operand1 (ALU-ALU FORWARDIND)
    -- 01-->MEM_WB_WillIWriteBack AND ID_EX_Operand2==MEM_WB_Operand1 (MEM-ALU FORWARDIND)
    -- 1x--> ELSE NO FORWARDIND

END ENTITY;

ARCHITECTURE implementation OF ForwardingUnit IS
BEGIN
    SEL_MUX_Operand1 <= "00" WHEN (EX_MEM_WillIWriteBack = '1') AND (ID_EX_Operand1 = EX_MEM_Operand1)
        ELSE
        "01" WHEN (MEM_WB_WillIWriteBack = '1') AND (ID_EX_Operand1 = MEM_WB_Operand1)
        ELSE
        "10";

    SEL_MUX_Operand2 <= "00" WHEN (EX_MEM_WillIWriteBack = '1') AND (ID_EX_Operand2 = EX_MEM_Operand1)
        ELSE
        "01" WHEN (MEM_WB_WillIWriteBack = '1') AND (ID_EX_Operand2 = MEM_WB_Operand1)
        ELSE
        "10";

END ARCHITECTURE;