vsim -gui work.hazarddetectionunit
add wave -position end  sim:/hazarddetectionunit/BT
add wave -position end  sim:/hazarddetectionunit/MEM
add wave -position end  sim:/hazarddetectionunit/OP1
add wave -position end  sim:/hazarddetectionunit/OP2
add wave -position end  sim:/hazarddetectionunit/LOAD_OP
add wave -position end  sim:/hazarddetectionunit/OUT1
add wave -position end  sim:/hazarddetectionunit/OUT2
add wave -position end  sim:/hazarddetectionunit/OUT3
force -freeze sim:/hazarddetectionunit/BT 0 0
force -freeze sim:/hazarddetectionunit/MEM 0 0
run
force -freeze sim:/hazarddetectionunit/BT 1 0
run
force -freeze sim:/hazarddetectionunit/BT 0 0
force -freeze sim:/hazarddetectionunit/OP1 001 0
force -freeze sim:/hazarddetectionunit/OP2 100 0
force -freeze sim:/hazarddetectionunit/LOAD_OP 000 0
run
force -freeze sim:/hazarddetectionunit/LOAD_OP 100 0
run
force -freeze sim:/hazarddetectionunit/MEM 1 0
run
force -freeze sim:/hazarddetectionunit/LOAD_OP 001 0
run
force -freeze sim:/hazarddetectionunit/OP1 101 0
run