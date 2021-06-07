LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE std.textio.ALL;
USE std.env.finish;

ENTITY ControlUnit_tb IS
END ControlUnit_tb;

ARCHITECTURE sim OF ControlUnit_tb IS

    CONSTANT clk_hz : INTEGER := 100e6;
    CONSTANT clk_period : TIME := 1 sec / clk_hz;

    SIGNAL clk : STD_LOGIC := '1';
    SIGNAL rst : STD_LOGIC := '1';

    SIGNAL instruction : STD_LOGIC_VECTOR(32 - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL IshouldStall, ALU_Src_ImmOrReg, ALU_Operation, MEM_Write, MEM_Read, MEM_useStack, WB_WBEnable, WB_MemToReg : STD_LOGIC;

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
BEGIN

    DUT : ControlUnit
    GENERIC MAP(
        n => 32
    )
    PORT MAP(
        instruction, IshouldStall, ALU_Src_ImmOrReg, ALU_Operation, MEM_Write, MEM_Read,
        MEM_useStack, WB_WBEnable, WB_MemToReg

    );
    SEQUENCER_PROC : PROCESS
    BEGIN
        --test case 1
        WAIT FOR clk_period * 2;

        instruction <= (OTHERS => '0');
        IshouldStall <= '0';

        WAIT FOR clk_period * 10;
        ASSERT ALU_Src_ImmOrReg = '0'AND ALU_Operation = '1'AND MEM_Write = '0'AND MEM_Read = '0'
        AND MEM_useStack = '0'AND WB_WBEnable = '0' AND WB_MemToReg = '0'
        REPORT "ERROR IN NOP INSTRUCTION"
            SEVERITY failure;

        --test case 2
        WAIT FOR clk_period * 2;

        instruction <= "01011010110101101011010110101101";
        IshouldStall <= '0';

        WAIT FOR clk_period * 10;
        ASSERT ALU_Src_ImmOrReg = '1'AND ALU_Operation = '0'AND MEM_Write = '0'AND MEM_Read = '1'
        AND MEM_useStack = '0'AND WB_WBEnable = '1' AND WB_MemToReg = '1'
        REPORT "ERROR IN LOAD INSTRUCTION"
            SEVERITY failure;

        --test case 3
        WAIT FOR clk_period * 2;

        instruction <= "01001010010100101001010010100101";
        IshouldStall <= '0';

        WAIT FOR clk_period * 10;
        ASSERT ALU_Src_ImmOrReg = '1'
        REPORT "ERROR IN POP INSTRUCTION"
            SEVERITY failure;

        ASSERT ALU_Operation = '0'
        REPORT "ERROR IN POP INSTRUCTION"
            SEVERITY failure;

        ASSERT MEM_Write = '0'
        REPORT "ERROR IN POP INSTRUCTION"
            SEVERITY failure;

        ASSERT MEM_Read = '1'
        REPORT "ERROR IN POP INSTRUCTION"
            SEVERITY failure;

        ASSERT
        MEM_useStack = '1'
        REPORT "ERROR IN POP INSTRUCTION"
            SEVERITY failure;

        ASSERT WB_MemToReg = '1'
        REPORT "ERROR IN POP INSTRUCTION"
            SEVERITY failure;

        finish;
    END PROCESS;

END ARCHITECTURE;