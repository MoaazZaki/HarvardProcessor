vsim -gui work.alu
add wave sim:/alu/*
force -freeze sim:/alu/operand1 32'hAAAAAAAA 0
force -freeze sim:/alu/operand2 32'hBBBBBBBB 0
force -freeze sim:/alu/flagsIN 3'h0 0

#for one operand
force -freeze sim:/alu/operation 5'h00 0
force -freeze sim:/alu/func 5'h01 0
run
force -freeze sim:/alu/func 5'h02 0
run
force -freeze sim:/alu/func 5'h03 0
run
force -freeze sim:/alu/func 5'h04 0
run
force -freeze sim:/alu/func 5'h05 0
run
force -freeze sim:/alu/func 5'h06 0
run
force -freeze sim:/alu/func 5'h07 0
run

#for two operands
force -freeze sim:/alu/operation 5'h01 0
run
force -freeze sim:/alu/operation 5'h02 0
run
force -freeze sim:/alu/operation 5'h03 0
run
force -freeze sim:/alu/operation 5'h04 0
run
force -freeze sim:/alu/operation 5'h05 0
run
force -freeze sim:/alu/operation 5'h06 0
run
force -freeze sim:/alu/operation 5'h07 0
run

#for memor and immediates
