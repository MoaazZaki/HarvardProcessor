.ORG 0
10
.ORG 10

#to test ALU-ALU forwarding
IADD R0,5 # R0 = 5 
MOV R0,R1 # R1 = 5 ALU forwarding of R0=5
ADD R1,R0 # R0= A MEM forwarding of R0=5, ALU forwarding of R1=5
SUB R1,R0 #R0=5 MEM fowarading of R0=A, ALU forwarding of R1=5
