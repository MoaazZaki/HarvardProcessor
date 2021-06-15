LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY RAM IS
	GENERIC (
		STORED_DATA_SIZE : INTEGER := 16;
		ADRESS_SIZE : INTEGER := 20;
		RAM_SIZE : INTEGER := 2 ** 20);
	PORT (
		clk, reset : IN STD_LOGIC;
		we : IN STD_LOGIC;
		address : IN STD_LOGIC_VECTOR(ADRESS_SIZE - 1 DOWNTO 0);
		sp_address : IN STD_LOGIC_VECTOR(ADRESS_SIZE - 1 DOWNTO 0);
		--To read and write two consecuetive places at a time
		datain : IN STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0);
		dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0);
		sp_dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0)
	);
END ENTITY RAM;

ARCHITECTURE sync_ram_a OF RAM IS
	TYPE ram_type IS ARRAY(0 TO RAM_SIZE - 1) OF STD_LOGIC_VECTOR(STORED_DATA_SIZE - 1 DOWNTO 0);
	SIGNAL ram : ram_type;
BEGIN

	PROCESS (clk, reset) IS
	BEGIN
		IF reset = '1' THEN
			--initialize the memory with zeros
			INITIALIZE_MEM : FOR i IN 0 TO RAM_SIZE - 1 LOOP
				ram(i) <= (OTHERS => '0');
			END LOOP INITIALIZE_MEM;

		ELSIF rising_edge(clk)
			THEN
			IF we = '1'
				THEN
				--Write two places at a time address-->MSBs, address+1-->LSBs
				ram(to_integer(unsigned((address)))) <= datain(STORED_DATA_SIZE * 2 - 1 DOWNTO STORED_DATA_SIZE);
				ram(to_integer(unsigned((address)) + 1)) <= datain(STORED_DATA_SIZE - 1 DOWNTO 0);
				-- ram(to_integer(unsigned((sp_address)))) <= datain(STORED_DATA_SIZE * 2 - 1 DOWNTO STORED_DATA_SIZE);
				-- ram(to_integer(unsigned((sp_address)) + 1)) <= datain(STORED_DATA_SIZE - 1 DOWNTO 0);
			END IF;
		END IF;
	END PROCESS;

	--Read two places at a time address-->MSBs, address+1-->LSBs
	dataout <= ram(to_integer(unsigned((address)))) & ram(to_integer(unsigned((address)) + 1));
	sp_dataout <= ram(to_integer(unsigned((sp_address)))) & ram(to_integer(unsigned((sp_address)) + 1));

END sync_ram_a;