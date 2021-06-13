vsim -gui work.pipelinedprocessor
add wave sim:/pipelinedprocessor/*

#force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ns} -r 100

#RESET
force -freeze sim:/pipelinedprocessor/reset 1 0
run
force -freeze sim:/pipelinedprocessor/reset 0 0
force -freeze sim:/pipelinedprocessor/INP 32'hAAAAAAAA 0

#INSTRUCTIONS=8--> clock cycles=5+26-1=30
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
run
run
