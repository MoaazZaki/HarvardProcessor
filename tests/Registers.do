vsim -gui work.registers
add wave -position end  sim:/registers/clk
add wave -position end  sim:/registers/reset
add wave -position end  sim:/registers/writeEnable
add wave -position end  sim:/registers/OP1
add wave -position end  sim:/registers/OP2
add wave -position end  sim:/registers/WADDRESS
add wave -position end  sim:/registers/WDATA
add wave -position end  sim:/registers/OUT1
add wave -position end  sim:/registers/OUT2
add wave -position end  sim:/registers/currentOperand
add wave -position end  sim:/registers/currentOutput
force -freeze sim:/registers/clk 0 0, 1 {50 ps} -r 100
force -freeze sim:/registers/reset 1 0
run
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /registers/READDEC
# ** Warning: NUMERIC_STD.TO_INTEGER: metavalue detected, returning 0
#    Time: 0 ps  Iteration: 0  Instance: /registers/READDEC
force -freeze sim:/registers/reset 0 0
force -freeze sim:/registers/writeEnable 1 0
force -freeze sim:/registers/WADDRESS 000 0
force -freeze sim:/registers/WDATA 16#5000 0
run
force -freeze sim:/registers/WADDRESS 010 0
force -freeze sim:/registers/WDATA 16#5643 0
run
force -freeze sim:/registers/OP1 000 0
force -freeze sim:/registers/OP2 010 0
force -freeze sim:/registers/writeEnable 0 0
run
run