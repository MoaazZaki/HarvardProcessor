LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY HazardDetectionUnit IS
    GENERIC (REG_SIZE : INTEGER := 3);
    PORT (
        BT, MEM : IN STD_LOGIC;
        OP1 : IN STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
        OP2 : IN STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
        LOAD_OP : IN STD_LOGIC_VECTOR(REG_SIZE - 1 DOWNTO 0);
        OUT1, OUT2, OUT3 : OUT STD_LOGIC
    );
END HazardDetectionUnit;

ARCHITECTURE myHDU OF HazardDetectionUnit IS
BEGIN
    PROCESS (BT, MEM, OP1, OP2, LOAD_OP)
    BEGIN
        OUT2 <= '1';
        OUT1 <= '1';
        IF BT = '1' THEN
            OUT3 <= '1';
        ELSIF MEM = '1' AND LOAD_OP = OP1 THEN
            OUT3 <= '1';
            OUT2 <= '0';
            OUT1 <= '0';
        ELSIF MEM = '1' AND LOAD_OP = OP2 THEN
            OUT3 <= '1';
            OUT2 <= '0';
            OUT1 <= '0';
        ELSE
            OUT3 <= '0';
        END IF;
    END PROCESS;
END ARCHITECTURE;