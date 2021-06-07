LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
    GENERIC (N : INTEGER := 32);
    PORT (
        -- INPUT
        operand1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        operand2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        operation : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        func : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        -- OUTPUT
        result : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
        flagsOUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"
    );

END ENTITY;

ARCHITECTURE struct OF ALU IS
BEGIN
    PROCESS (operand1, operand2, operation, func) -- if flagsIN should be included make it (all)
        VARIABLE operandComplement : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        VARIABLE tempResultPlusCarry : STD_LOGIC_VECTOR(N DOWNTO 0);
        VARIABLE tempResult : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    BEGIN
        IF (operation = "00000") THEN --ONE-OPERAND OPERATIONS
            IF (func = "00000") THEN --No operation
                flagsOUT <= "000";
            ELSIF (func = "00001") THEN --Set carry
                flagsOUT(2) <= '1';
            ELSIF (func = "00010") THEN --Clear carry
                flagsOUT(2) <= '0';
            ELSIF (func = "00011") THEN --Not
                operandComplement := NOT (operand1);
                result <= operandComplement;
                IF (to_integer(unsigned(operandComplement)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSIF (operandComplement(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                END IF;
            ELSIF (func = "00100") THEN --increment 
                tempResultPlusCarry := STD_LOGIC_VECTOR(unsigned('0' & operand1) + to_unsigned(1, N));
                IF (to_integer(unsigned(tempResultPlusCarry)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSIF (tempResultPlusCarry(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                END IF;
                result <= tempResultPlusCarry(N - 1 DOWNTO 0);
                flagsOUT(2) <= tempResultPlusCarry(N);

            ELSIF (func = "00101") THEN --decrement
                tempResultPlusCarry := STD_LOGIC_VECTOR(unsigned('0' & operand1) - to_unsigned(1, N));
                IF (to_integer(unsigned(tempResultPlusCarry)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSIF (tempResultPlusCarry(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                END IF;
                result <= tempResultPlusCarry(N - 1 DOWNTO 0);
                flagsOUT(2) <= tempResultPlusCarry(N);
            ELSIF (func = "00110") THEN --out
                result <= operand1;
            ELSE --in
            END IF;
        ELSE --TWO-OPERAND OPERATIONS
            IF (operation = "00001" OR operation = "01110") THEN --Move (either register or immediate)
                result <= operand1;
            ELSIF (operation = "00011") THEN --Sub
                tempResultPlusCarry := STD_LOGIC_VECTOR(unsigned('0' & operand1) - unsigned('0' & operand2));
                IF (to_integer(unsigned(tempResultPlusCarry)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSIF (tempResultPlusCarry(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                END IF;
                result <= tempResultPlusCarry(N - 1 DOWNTO 0);
                flagsOUT(2) <= tempResultPlusCarry(N);
            ELSIF (operation = "00100") THEN --And
                tempResult := operand1 AND operand2;
                IF (to_integer(unsigned(tempResult)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSIF (tempResult(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                END IF;
                result <= tempResult;

            ELSIF (operation = "00101") THEN --Or
                tempResult := operand1 OR operand2;
                IF (to_integer(unsigned(tempResult)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSIF (tempResult(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                END IF;
                result <= tempResult;
            ELSIF (operation = "00110") THEN --Sheft left 
                -- result <= STD_LOGIC_VECTOR(ununsigned(operand1) SLL ununsigned(func));
                -- TODO:UPDATE CARRY
            ELSIF (operation = "00111") THEN --Sheft right
                -- result <= STD_LOGIC_VECTOR(ununsigned(operand1) SRL ununsigned(func));
                -- TODO:UPDATE CARRY
            ELSE --Add (this is for ALU operations and even memory operations as well)
                tempResultPlusCarry := STD_LOGIC_VECTOR(unsigned('0' & operand1) + unsigned('0' & operand2));
                IF (to_integer(unsigned(tempResultPlusCarry)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSIF (tempResultPlusCarry(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                END IF;
                result <= tempResultPlusCarry(N - 1 DOWNTO 0);
                flagsOUT(2) <= tempResultPlusCarry(N);
            END IF;
        END IF;
    END PROCESS;
END struct;