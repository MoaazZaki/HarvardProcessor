LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY RegisterDFF IS
GENERIC ( n : integer := 32);
PORT( clk,reset,enable : IN std_logic;
d : IN std_logic_vector(n-1 DOWNTO 0);
q : OUT std_logic_vector(n-1 DOWNTO 0));
END RegisterDFF;

ARCHITECTURE mynDFF of RegisterDFF is
BEGIN

	PROCESS (clk,reset)
	BEGIN
		IF reset = '1' THEN q <= (OTHERS=>'0');
		ELSIF rising_edge(clk) and enable = '1' THEN q <= d;
		END IF;
	END PROCESS;
END ARCHITECTURE;

