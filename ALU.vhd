LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity ALU is 
port(
A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
Cin : in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic;
s : in std_logic_vector(3 downto 0));

end entity;

ARCHITECTURE struct OF ALU IS

COMPONENT partA IS
PORT (
A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
Cin : in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic;
s : in std_logic_vector(1 downto 0));
END COMPONENT ;

COMPONENT partB IS
PORT (
A : in std_logic_vector(15 downto 0);
B : in std_logic_vector(15 downto 0);
F : out std_logic_vector(15 downto 0);
s : in std_logic_vector(1 downto 0));
END COMPONENT ;

COMPONENT partC IS
PORT (
A : in std_logic_vector(15 downto 0);
Cin : in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic;
s : in std_logic_vector(1 downto 0));
END COMPONENT ;

COMPONENT partD IS
PORT (
A : in std_logic_vector(15 downto 0);
Cin : in std_logic;
F : out std_logic_vector(15 downto 0);
Cout : out std_logic;
s : in std_logic_vector(1 downto 0));
END COMPONENT ;

SIGNAL F1,F2,F3,F4 : std_logic_vector(15 downto 0);

SIGNAL Cout1,Cout2,Cout3,Cout4 : std_logic;
BEGIN
a1: partA PORT MAP(A,B,Cin,F1,Cout1,s(1 downto 0));
b1: partB PORT MAP(A,B,F2,s(1 downto 0));
c1: partC PORT MAP(A,Cin,F3,Cout3,s(1 downto 0));
d1: partD PORT MAP(A,Cin,F4,Cout4,s(1 downto 0));

F<= F1 when s(3 downto 2) = "00"
ELSE F2 when s(3 downto 2) = "01"
ELSE F3 when s(3 downto 2) = "10"
ELSE F4 when s(3 downto 2) = "11";

Cout<= Cout1 when s(3 downto 2) = "00"
ELSE Cout2 when s(3 downto 2) = "01"
ELSE Cout3 when s(3 downto 2) = "10"
ELSE Cout4 when s(3 downto 2) = "11";


END struct;