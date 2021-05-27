LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Registers IS
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
END Registers;

ARCHITECTURE regs OF Registers IS
    -- COMPONENTS
    COMPONENT RegisterDFF IS
        PORT (
            clk, reset, enable : IN STD_LOGIC;
            d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;
    ---
    COMPONENT TriStateBuffer IS
        PORT (
            input : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
            enable : IN STD_LOGIC;
            output : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
    END COMPONENT;
    ---
    COMPONENT VectorDecoder IS
        PORT (
            enable : IN STD_LOGIC;
            INDEX : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0);
            VECTOR : OUT STD_LOGIC_VECTOR(REGS_NUM - 1 DOWNTO 0));
    END COMPONENT;
    -- SIGNALS
    SIGNAL registersInputEnable : STD_LOGIC_VECTOR(REGS_NUM - 1 DOWNTO 0);
    SIGNAL registersOut1Enable : STD_LOGIC_VECTOR(REGS_NUM - 1 DOWNTO 0);
    SIGNAL registersOut2Enable : STD_LOGIC_VECTOR(REGS_NUM - 1 DOWNTO 0);
    SIGNAL registersOutput : STD_LOGIC_VECTOR((REGS_NUM * n) - 1 DOWNTO 0);
    SIGNAL notClk : STD_LOGIC;
BEGIN
    --  Registers 
    REGLOOP : FOR i IN 0 TO REGS_NUM - 1 GENERATE
        REGS : RegisterDFF PORT MAP(notClk, reset, registersInputEnable(i), WDATA, registersOutput((i + 1) * n - 1 DOWNTO i * n));
    END GENERATE;
    -- Tristate Buffer of OP1 
    TRILOOPOP1 : FOR i IN 0 TO REGS_NUM - 1 GENERATE
        TRISOP1 : TriStateBuffer PORT MAP(registersOutput((i + 1) * n - 1 DOWNTO i * n), registersOut1Enable(i), OUT1);
    END GENERATE;
    -- Tristate Buffer of OP2 
    TRILOOPOP2 : FOR i IN 0 TO REGS_NUM - 1 GENERATE
        TRISOP2 : TriStateBuffer PORT MAP(registersOutput((i + 1) * n - 1 DOWNTO i * n), registersOut2Enable(i), OUT2);
    END GENERATE;
    -- Decoder
    WRITEDEC : VectorDecoder PORT MAP(writeEnable, WADDRESS, registersInputEnable);
    READOP1DEC : VectorDecoder PORT MAP('1', OP1, registersOut1Enable); -- enable ?
    READOP2DEC : VectorDecoder PORT MAP('1', OP2, registersOut2Enable); -- enable ?
    -- Clk
    notClk <= NOT clk;
END ARCHITECTURE;