LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY ALU IS
    GENERIC (N : INTEGER := 32);
    PORT (
        -- INPUT
        operand1 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
        operand2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
        operation : IN STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
        func : IN STD_LOGIC_VECTOR(4 DOWNTO 0 ):= (OTHERS => '0');
        -- OUTPUT
        result : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
        flagsOUT : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) := "000"
    );

END ENTITY;

ARCHITECTURE struct OF ALU IS
BEGIN
    PROCESS (operand1, operand2, operation, func)
        VARIABLE operandComplement : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        VARIABLE tempResultPlusCarry : STD_LOGIC_VECTOR(N DOWNTO 0);
        VARIABLE tempResult : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        VARIABLE subCarry : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        VARIABLE subResult : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
    BEGIN
        IF (operation = "00000") THEN --ONE-OPERAND OPERATIONS
            IF (func = "00000") THEN --No operation
                -- flagsOUT <= "000";
                -- result <= (OTHERS => '0');
            ELSIF (func = "00001") THEN --Set carry
                flagsOUT(2) <= '1';
            ELSIF (func = "00010") THEN --Clear carry
                flagsOUT(2) <= '0';
            ELSIF (func = "00011") THEN --Not
                operandComplement := NOT (operand1);
                result <= operandComplement;
                IF (to_integer(unsigned(operandComplement)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSE
                    flagsOUT(0) <= '0'; --clear zero flag
                END IF;
                IF (operandComplement(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                ELSE
                    flagsOUT(1) <= '0'; --clear negative flag
                END IF;

            ELSIF (func = "00100") THEN --increment 
                tempResultPlusCarry := STD_LOGIC_VECTOR(unsigned('0' & operand1) + to_unsigned(1, N));
                IF (to_integer(unsigned(tempResultPlusCarry)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSE
                    flagsOUT(0) <= '0'; --clear zero flag
                END IF;
                IF (tempResultPlusCarry(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                ELSE
                    flagsOUT(1) <= '0'; --clear negative flag
                END IF;
                result <= tempResultPlusCarry(N - 1 DOWNTO 0);
                flagsOUT(2) <= tempResultPlusCarry(N);

            ELSIF (func = "00101") THEN --decrement
                tempResult := STD_LOGIC_VECTOR(unsigned(operand1) - to_unsigned(1, N));
                IF (to_integer(unsigned(tempResult)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSE
                    flagsOUT(0) <= '0'; --clear zero flag
                END IF;
                IF (tempResult(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                ELSE
                    flagsOUT(1) <= '0'; --clear negative flag
                END IF;
                flagsOUT(2) <= operand2(N-1) NAND tempResult(N-1);      --assign the carry flag
                result <= tempResult(N - 1 DOWNTO 0);
                --flagsOUT(2) <= tempResult(N);

            ELSIF (func = "00110") THEN --out
                result <= operand1;
            ELSE --in
                result <= operand1;
            END IF;

        ELSE --TWO-OPERAND OPERATIONS
            IF (operation = "00001" OR operation = "01110") THEN --Move (either register or immediate)
                result <= operand2;
            ELSIF (operation = "00011") THEN --Sub
                
                --subtraction using 1's complement
                tempResultPlusCarry := STD_LOGIC_VECTOR(unsigned('0' & operand2) + NOT unsigned('0' & operand1));
                subCarry := (OTHERS => '0');
                subCarry(0) := tempResultPlusCarry(N);
                subResult := STD_LOGIC_VECTOR(unsigned(tempResultPlusCarry(N - 1 DOWNTO 0)) + unsigned(subCarry));      --adding any resulting carry
                
                IF (to_integer(unsigned(subResult)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSE
                    flagsOUT(0) <= '0'; --clear zero flag
                END IF;
                IF (subResult(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                ELSE
                    flagsOUT(1) <= '0'; --clear negative flag
                END IF;
                flagsOUT(2) <= operand2(N-1) NAND subResult(N-1);      --assign the carry flag
                result <= subResult;
                --flagsOUT(2) <= tempResult(N);

            ELSIF (operation = "00100") THEN --And
                tempResult := operand1 AND operand2;
                IF (to_integer(unsigned(tempResult)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSE
                    flagsOUT(0) <= '0'; --clear zero flag
                END IF;
                IF (tempResult(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                ELSE
                    flagsOUT(1) <= '0'; --clear negative flag
                END IF;
                result <= tempResult;

            ELSIF (operation = "00101") THEN --Or
                tempResult := operand1 OR operand2;
                IF (to_integer(unsigned(tempResult)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSE
                    flagsOUT(0) <= '0'; --clear zero flag
                END IF;
                IF (tempResult(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                ELSE
                    flagsOUT(1) <= '0'; --clear negative flag
                END IF;
                result <= tempResult;

            ELSIF (operation = "00110") THEN --Shift left 
                result <= STD_LOGIC_VECTOR(shift_left(unsigned(operand1), to_integer(unsigned(func))));
                flagsOUT(2) <= operand1(N - to_integer(unsigned(func)));

            ELSIF (operation = "00111") THEN --Shift right
                result <= STD_LOGIC_VECTOR(shift_right(unsigned(operand1), to_integer(unsigned(func))));
                flagsOUT(2) <= operand1(to_integer(unsigned(func)) - 1);

            ELSE --Add (this is for ALU operations and even memory operations as well)
                tempResultPlusCarry := STD_LOGIC_VECTOR(unsigned('0' & operand1) + unsigned('0' & operand2));
                IF (to_integer(unsigned(tempResultPlusCarry)) = 0) THEN --set zero flag
                    flagsOUT(0) <= '1';
                ELSE
                    flagsOUT(0) <= '0'; --clear zero flag
                END IF;
                IF (tempResultPlusCarry(N - 1) = '1') THEN --set negative flag
                    flagsOUT(1) <= '1';
                ELSE
                    flagsOUT(1) <= '0'; --clear negative flag
                END IF;
                result <= tempResultPlusCarry(N - 1 DOWNTO 0);
                flagsOUT(2) <= tempResultPlusCarry(N);
            END IF;
        END IF;
    END PROCESS;
END struct;