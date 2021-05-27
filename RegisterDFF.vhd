LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY RegisterDFF IS
	GENERIC (n : INTEGER := 32);
	PORT (
		clk, reset, enable : IN STD_LOGIC;
		d : IN STD_LOGIC_VECTOR(n - 1 DOWNTO 0);
		q : OUT STD_LOGIC_VECTOR(n - 1 DOWNTO 0));
END RegisterDFF;

ARCHITECTURE mynDFF OF RegisterDFF IS
BEGIN

	PROCESS (clk, reset)
	BEGIN
		IF reset = '1' THEN
			q <= (OTHERS => '0');
		ELSIF rising_edge(clk) AND enable = '1' THEN
			q <= d;
		END IF;
	END PROCESS;
END ARCHITECTURE;