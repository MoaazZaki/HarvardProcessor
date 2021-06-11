LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY RegisterPC IS
    GENERIC (n : INTEGER := 32);
    PORT (
        clk, reset, enable : IN STD_LOGIC;
        memoryOfZero : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
        q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END RegisterPC;

ARCHITECTURE mynPC OF RegisterPC IS
BEGIN

    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            q <= (31 DOWNTO 16 => '0') & memoryOfZero;
        ELSIF rising_edge(clk) AND enable = '1' THEN
            q <= d;
        END IF;
    END PROCESS;
END ARCHITECTURE;