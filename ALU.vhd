LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY ALU IS
    PORT (
        -- INPUT
        operand1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        operand2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        flagsIN : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        operation : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        func : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- OUTPUT
        result : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        flagsOUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );

END ENTITY;

ARCHITECTURE struct OF ALU IS
    --declare any temp signals here
BEGIN
    PROCESS (operand1, operand2, operation, func) -- if flagsIN should be included make it (all)
    BEGIN
        IF (operation = "00000") THEN --ONE-OPERAND OPERATIONS
            IF (func = "00000") THEN --No operation
                flagsOUT <= "000";
            ELSIF (func = "00001") THEN --Set carry
                flagsOUT(2) <= '1';
            ELSIF (func = "00010") THEN --Clear carry
                flagsOUT(2) <= '0';
            ELSIF (func = "00011") THEN --Not
                result <= NOT (operand1);
            ELSIF (func = "00100") THEN --increment 
            ELSIF (func = "00101") THEN --decrement
            ELSIF (func = "00110") THEN --out
            ELSE --in
            END IF;
        ELSE --TWO-OPERAND OPERATIONS
            IF (operation = "00001" OR operation = "01110") THEN --Move (either register or immediate)
                result <= operand1;
            ELSIF (operation = "00011") THEN --Sub
            ELSIF (operation = "00100") THEN --And
            ELSIF (operation = "00101") THEN --Or
            ELSIF (operation = "00110") THEN --Sheft left 
            ELSIF (operation = "00111") THEN --Sheft right
            ELSE --Add (this is for ALU operations and even memory operations as well)
            END IF;
        END IF;
    END PROCESS;
END struct;