vsim -gui work.vectordecoder
add wave -position end  sim:/vectordecoder/enable
add wave -position end  sim:/vectordecoder/INDEX
add wave -position end  sim:/vectordecoder/VECTOR
force -freeze sim:/vectordecoder/enable 0 0
run
force -freeze sim:/vectordecoder/INDEX 000 0
run
run
force -freeze sim:/vectordecoder/INDEX 001 0
run
force -freeze sim:/vectordecoder/INDEX 000 0
force -freeze sim:/vectordecoder/enable 1 0
run
force -freeze sim:/vectordecoder/INDEX 001 0
run
force -freeze sim:/vectordecoder/INDEX 010 0
run
force -freeze sim:/vectordecoder/INDEX 011 0
run
force -freeze sim:/vectordecoder/INDEX 100 0
run
force -freeze sim:/vectordecoder/INDEX 101 0
run
force -freeze sim:/vectordecoder/INDEX 110 0
run
force -freeze sim:/vectordecoder/INDEX 111 0
run