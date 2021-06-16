LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY BranchForwardingUnit IS

    GENERIC (ADD_SIZE : INTEGER := 3; INST_SIZE : INTEGER := 32); 
    PORT (
        ID_ADD, MEM_WB_ADD, EX_WB_ADD : IN STD_LOGIC_VECTOR(ADD_SIZE-1 DOWNTO 0) := (OTHERS => '0');
        ID_OUT, EX_OUT, MEM_OUT: IN STD_LOGIC_VECTOR(INST_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
        BRANCH_DST : OUT STD_LOGIC_VECTOR(INST_SIZE - 1 DOWNTO 0));

END ENTITY;

ARCHITECTURE BFUarch OF BranchForwardingUnit IS
BEGIN

    --check if branch operand is the result of a previous instruction (EX,MEM)
    BRANCH_DST <= EX_OUT WHEN ID_ADD = EX_WB_ADD    
    ELSE MEM_OUT WHEN ID_ADD = MEM_WB_ADD
    ELSE ID_OUT;    --if not, take the current operand as it is

END ARCHITECTURE;