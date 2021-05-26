LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Registers IS
    GENERIC (
        REGS_NUM : INTEGER := 8;
        REGS_INDEX_SIZE : INTEGER := 3;
        n : INTEGER := 32);
    PORT (
        clk, reset, writeEnable : IN STD_LOGIC;
        OP1 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE DOWNTO 0);
        OP2 : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE DOWNTO 0);
        WADDRESS : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE DOWNTO 0);
        WDATA : IN STD_LOGIC_VECTOR(REGS_INDEX_SIZE DOWNTO 0);
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
    SIGNAL registersOutputEnable : STD_LOGIC_VECTOR(REGS_NUM - 1 DOWNTO 0);
    SIGNAL registersOutput : STD_LOGIC_VECTOR((REGS_NUM * n) - 1 DOWNTO 0);
    SIGNAL currentOperand : STD_LOGIC_VECTOR(REGS_INDEX_SIZE - 1 DOWNTO 0);
    SIGNAL currentOutput : STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
    SIGNAL notClk : STD_LOGIC;
BEGIN
    --  Registers 
    REGLOOP : FOR i IN 0 TO REGS_NUM - 1 GENERATE
        REGS : RegisterDFF PORT MAP(notClk, reset, registersInputEnable(i), WDATA, registersOutput((i + 1) * n - 1 DOWNTO i * n));
    END GENERATE;
    -- Tristate Buffer of Registers
    TRILOOP : FOR i IN 0 TO REGS_NUM - 1 GENERATE
        TRIS : TriStateBuffer PORT MAP(registersOutput((i + 1) * n - 1 DOWNTO i * n), registersOutputEnable(i), currentOutput);
    END GENERATE;
    -- Decoder
    WRITEDEC : VectorDecoder PORT MAP(writeEnable, WADDRESS, registersInputEnable);
    READDEC : VectorDecoder PORT MAP('1', currentOperand, registersOutputEnable); -- enable ?
    -- Process
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            currentOperand <= OP1;
            OUT1 <= currentOutput;
            currentOperand <= OP2;
            OUT2 <= currentOutput;
        END IF;
    END PROCESS;
    notClk <= NOT clk;
END ARCHITECTURE;