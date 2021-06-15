.ORG 0
10
.ORG 10
LDM R0,19 # R0 = 19                           10
LDM R4,19 # R4 = 19                           12
LDM R3, 1D #R3 = 1D                           14
NOP                                           16
SUB R0, R4                                    17
JZ R3                                         18
STD R0,2(R0) # M(19) = 17 , WAW, RAW          19
LDD R1,2(R0) # R1 = M(1B)                     1B
INC R0 # R0 = 16 ,LOAD USE CASE               1D
#END OF MY COOL PROGRAM