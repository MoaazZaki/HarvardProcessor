LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY JumpControl IS
    GENERIC (N : INTEGER := 5);
    PORT (
        operation : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        flags : IN STD_LOGIC(2 DOWNTO 0);
        branchTaken: OUT STD_LOGIC
    );
END JumpControl;

ARCHITECTURE jumpControlArch OF JumpControl IS 
BEGIN 

  branchTaken <= '0' WHEN (operation(N-1) = '0')             --Not a branch instruction
  ELSE flags(0) WHEN (operation(N-3 DOWNTO 0) = '000')       --Zero flag (JZ)
  ELSE flags(1) WHEN (operation(N-3 DOWNTO 0) = '001')       --Negative flag (JN)
  ELSE flags(2) WHEN (operation(N-3 DOWNTO 0) = '010')       --Carry flag (JC)  
  ELSE '1';                                                  --uncondition jumps (JMP, CALL, RET)

END ARCHITECTURE 