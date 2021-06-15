vsim -gui work.pipelinedprocessor
add wave sim:/pipelinedprocessor/REG_READ_WRITE/OUT1
add wave sim:/pipelinedprocessor/REG_READ_WRITE/OUT2
add wave sim:/pipelinedprocessor/REG_READ_WRITE/registersOutput
add wave sim:/pipelinedprocessor/ALU_FLAGS_OUT
add wave sim:/pipelinedprocessor/clk
add wave sim:/pipelinedprocessor/reset
add wave sim:/pipelinedprocessor/ALU_FLAGS_STORED
add wave sim:/pipelinedprocessor/PC_OUT
add wave sim:/pipelinedprocessor/SP_OUT
add wave sim:/pipelinedprocessor/INP
add wave sim:/pipelinedprocessor/OUTP
add wave sim:/pipelinedprocessor/ValueToWriteBackToReg_MEM_WB
add wave sim:/pipelinedprocessor/ValueToWriteBackToReg_EX_MEM

force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ps} -r 100
#force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ns} -r 100

#RESET
force -freeze sim:/pipelinedprocessor/reset 1 0
run
force -freeze sim:/pipelinedprocessor/reset 0 0
force -freeze sim:/pipelinedprocessor/INP 32'hAAAAAAAA 0

#INSTRUCTIONS=8--> clock cycles=5+7-1=11
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