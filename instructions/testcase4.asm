.ORG 0
10
.ORG 10

IADD R0,5 # R0 = 5
MOV R0,R1 # R1 = 5
IADD R1,7 # R1= C
STD R1,7(R0) #anything
LDD R5,7(R0) #R5= C
INC R4 #R4=1
INC R5 #R5= D