vsim -gui work.pipelinedprocessor
add wave sim:/pipelinedprocessor/clk
add wave sim:/pipelinedprocessor/reset
add wave sim:/pipelinedprocessor/PC_OUT
add wave sim:/pipelinedprocessor/SP_OUT
add wave sim:/pipelinedprocessor/INP
add wave sim:/pipelinedprocessor/OUTP
add wave sim:/pipelinedprocessor/REG_READ_WRITE/registersOutput
add wave sim:/pipelinedprocessor/ALU_FLAGS_OUT
add wave sim:/pipelinedprocessor/ALU_MODULE/operand1 
add wave sim:/pipelinedprocessor/ALU_MODULE/operand2 
add wave sim:/pipelinedprocessor/ALU_MODULE/operation 
add wave sim:/pipelinedprocessor/ALU_MODULE/func 
add wave sim:/pipelinedprocessor/ALU_MODULE/result 
add wave sim:/pipelinedprocessor/ALU_MODULE/flagsOUT

force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ps} -r 100
#force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ns} -r 100

#RESET
force -freeze sim:/pipelinedprocessor/reset 1 0
run
force -freeze sim:/pipelinedprocessor/reset 0 0

#INSTRUCTIONS=13--> clock cycles=5+13-1=17

force -freeze sim:/pipelinedprocessor/INP 16#00000005 0
run
force -freeze sim:/pipelinedprocessor/INP 16#00000019 0
run
force -freeze sim:/pipelinedprocessor/INP 16#FFFFFFFF 0
run
force -freeze sim:/pipelinedprocessor/INP 16#FFFFF320 0
run
run
run
run
run
run
run
run
run
run
run
run
run
run
