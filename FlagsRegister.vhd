LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY FlagsRegister IS
	GENERIC (n : INTEGER := 32);
	PORT (
		clk, reset, enable : IN STD_LOGIC := '1';
		d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0) := (OTHERS => '0');
		q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END FlagsRegister;

ARCHITECTURE flagsRegArch OF FlagsRegister IS
BEGIN

	PROCESS (clk, reset)
	BEGIN
		IF reset = '1' THEN
			q <= (OTHERS => '0');
		ELSIF falling_edge(clk) AND enable = '1' THEN
			q <= d;
		END IF;
	END PROCESS;

END ARCHITECTURE;