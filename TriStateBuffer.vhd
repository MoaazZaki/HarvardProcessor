LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY TriStateBuffer IS
GENERIC ( n : integer := 32);
PORT(
input: in std_logic_vector(n-1 DOWNTO 0);
enable : in std_logic;
output : out std_logic_vector(n-1 DOWNTO 0));
END TriStateBuffer;

ARCHITECTURE myBuffer of TriStateBuffer is
BEGIN
WITH enable SELECT
	output <= (OTHERS => 'Z') WHEN '0',
		   input WHEN OTHERS;
END ARCHITECTURE;