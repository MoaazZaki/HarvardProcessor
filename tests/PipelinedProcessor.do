vsim -gui work.pipelinedprocessor
add wave -position end  sim:/pipelinedprocessor/clk
add wave -position end  sim:/pipelinedprocessor/reset
add wave -position end  sim:/pipelinedprocessor/INTSRUCTION
add wave -position end  sim:/pipelinedprocessor/OUTP
add wave -position end  sim:/pipelinedprocessor/NOTHINGREG
add wave -position end  sim:/pipelinedprocessor/NOTHINGDATA
add wave -position end  sim:/pipelinedprocessor/DECODEOUT1
add wave -position end  sim:/pipelinedprocessor/DECODEOUT2
add wave -position end  sim:/pipelinedprocessor/ID_EX_IN
add wave -position end  sim:/pipelinedprocessor/ID_EX_OUT
add wave -position end  sim:/pipelinedprocessor/ALU_OUT
add wave -position end  sim:/pipelinedprocessor/ALU_FLAGS_OUT
add wave -position end  sim:/pipelinedprocessor/MEM_WB_IN
add wave -position end  sim:/pipelinedprocessor/MEM_WB_OUT
force -freeze sim:/pipelinedprocessor/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/pipelinedprocessor/reset 1 0
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#00000000 0
run
force -freeze sim:/pipelinedprocessor/reset 0 0
force -freeze sim:/pipelinedprocessor/INTSRUCTION 16#01040000 0
run
run
run
run
run
run
run 