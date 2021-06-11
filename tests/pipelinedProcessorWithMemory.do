vsim -gui work.pipelinedprocessor
add wave sim:/pipelinedprocessor/*

#force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ns} -r 100

#RESET
force -freeze sim:/pipelinedprocessor/reset 1 0
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#00000000 0
run
force -freeze sim:/pipelinedprocessor/reset 0 0

#INSTRUCTIONS

#INC REG0
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#00040000 0
run

#NOT REG1
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#01030000 0
run

#SHL REG2,1
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#32010000 0
run

#SHL REG2,1
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#32010000 0
run

#STORE REG1,7(REG0)
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#502000E0 0
run

#INC REG3
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#03040000 0
run

#INC REG4
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#04040000 0
run

#LOAD REG5, 7(REG0)
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#58A000E0 0
run
run
run
run




