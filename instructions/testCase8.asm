.ORG 0
10
.ORG 10

#to test ALU-ALU forwarding
IADD R0,1B # R0 = 5      10
NOP # 12
NOP # 13
NOP # 14
CALL R0 # 15
NOP # 16
NOP # 17
NOP # 18
NOP # 19
NOP # 1A
LDM R1,2(R0) # 1B
LDM R2,2(R0) # 1D
IADD R1, 5 # 1F
RET # 21