vsim -gui work.pipelinedprocessor
add wave sim:/pipelinedprocessor/*

#force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ns} -r 100

#RESET
force -freeze sim:/pipelinedprocessor/reset 1 0
run
force -freeze sim:/pipelinedprocessor/reset 0 0

#INSTRUCTIONS=8--> clock cycles=5+8-1=12
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




