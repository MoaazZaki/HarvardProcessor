LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY VectorDecoder IS
    GENERIC (
        VECTOR_SIZE : INTEGER := 8;
        INDEX_SIZE : INTEGER := 3);
    PORT (
        enable : IN STD_LOGIC :='0';
        INDEX : IN STD_LOGIC_VECTOR(INDEX_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
        VECTOR : OUT STD_LOGIC_VECTOR(VECTOR_SIZE - 1 DOWNTO 0));
END VectorDecoder;

ARCHITECTURE myDecoder OF VectorDecoder IS
BEGIN
    PROCESS (enable, INDEX)
    BEGIN
        VECTOR <= (OTHERS => '0');
        IF (enable = '1') THEN
            VECTOR(to_integer(unsigned((INDEX)))) <= '1';
        END IF;
    END PROCESS;
END ARCHITECTURE;