LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
USE std.textio.ALL;

ENTITY ROM IS
    GENERIC (
        STORED_DATA_SIZE : INTEGER := 16;
        ADRESS_SIZE : INTEGER := 20;
        ROM_SIZE : INTEGER := 2 ** 20);
    PORT (
        address : IN STD_LOGIC_VECTOR(ADRESS_SIZE - 1 DOWNTO 0);
        --To read and write two consecuetive places at a time
        dataout : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE * 2 - 1 DOWNTO 0);
        memoryOfZeroForPCReset : OUT STD_LOGIC_VECTOR(STORED_DATA_SIZE - 1 DOWNTO 0));
END ENTITY ROM;

ARCHITECTURE sync_ROM_a OF ROM IS
    TYPE ROM_type IS ARRAY(0 TO ROM_SIZE - 1) OF STD_LOGIC_VECTOR(STORED_DATA_SIZE - 1 DOWNTO 0);

    --Those functions are taken from that blog
    --https://vhdlwhiz.com/initialize-ram-from-file/
    --Author: Jonas Julian Jensen
    --one is used to initialize the memory from a binary file
    --and the other to initialize the memory from a hexa file
    IMPURE FUNCTION init_rom_bin RETURN ROM_type IS
        FILE text_file : text OPEN read_mode IS "instructions\\rom_content_bin.txt";
        VARIABLE text_line : line;
        VARIABLE ram_content : ROM_type;
        VARIABLE bv : bit_vector(ram_content(0)'RANGE);
    BEGIN
        FOR i IN 0 TO ROM_SIZE - 1 LOOP
            -- FOR i IN 0 TO 9 LOOP
            readline(text_file, text_line);
            read(text_line, bv);
            ram_content(i) := To_StdLogicVector(bv);
        END LOOP;

        RETURN ram_content;
    END FUNCTION;

    IMPURE FUNCTION init_rom_hex RETURN ROM_type IS
        FILE text_file : text OPEN read_mode IS "instructions\\rom_content_hex.txt";
        VARIABLE text_line : line;
        VARIABLE ram_content : ROM_type;
        VARIABLE c : CHARACTER;
        VARIABLE offset : INTEGER;
        VARIABLE hex_val : STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN
        FOR i IN 0 TO ROM_SIZE - 1 LOOP
            -- FOR i IN 0 TO 9 LOOP
            readline(text_file, text_line);

            offset := 0;

            WHILE offset < ram_content(i)'high LOOP
                read(text_line, c);

                CASE c IS
                    WHEN '0' => hex_val := "0000";
                    WHEN '1' => hex_val := "0001";
                    WHEN '2' => hex_val := "0010";
                    WHEN '3' => hex_val := "0011";
                    WHEN '4' => hex_val := "0100";
                    WHEN '5' => hex_val := "0101";
                    WHEN '6' => hex_val := "0110";
                    WHEN '7' => hex_val := "0111";
                    WHEN '8' => hex_val := "1000";
                    WHEN '9' => hex_val := "1001";
                    WHEN 'A' | 'a' => hex_val := "1010";
                    WHEN 'B' | 'b' => hex_val := "1011";
                    WHEN 'C' | 'c' => hex_val := "1100";
                    WHEN 'D' | 'd' => hex_val := "1101";
                    WHEN 'E' | 'e' => hex_val := "1110";
                    WHEN 'F' | 'f' => hex_val := "1111";

                    WHEN OTHERS =>
                        hex_val := "XXXX";
                        ASSERT false REPORT "Found non-hex character '" & c & "'";
                END CASE;

                ram_content(i)(ram_content(i)'high - offset
                DOWNTO ram_content(i)'high - offset - 3) := hex_val;
                offset := offset + 4;

            END LOOP;
        END LOOP;

        RETURN ram_content;
    END FUNCTION;
    ---end of initialization functions
    SIGNAL ROM : ROM_type := init_rom_bin;
BEGIN
    --READ ONLY MEMORY no writing is required
    --Read two places at a time address-->MSBs, address+1-->LSBs
    dataout <= ROM(to_integer(unsigned((address)))) & ROM(to_integer(unsigned((address)) + 1));
    memoryOfZeroForPCReset <= ROM(0);
END sync_ROM_a;