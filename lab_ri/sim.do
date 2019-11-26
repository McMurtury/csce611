#vlog *.sv
#vlog *.sv

#restart -f

#restart -f
vlog -novopt *.sv
vsim -novopt work.cpu

#add everything
#add wave -r /cpu/*

# -------------------------------------- #
# --- Adding wave forms automatically -- # 
# -------------------------------------- #


force -freeze sim:/cpu/clk 1 0, 0 {50 ns} -r 100

#add wave -r /*

add wave /cpu/clk
add wave /cpu/rst
add wave /cpu/PC_FETCH
add wave /cpu/instruction_EX
add wave /cpu/gpio_out
add wave /cpu/op_EX
add wave /cpu/rdrt_EX
add wave /cpu/regwrite_WB
add wave /cpu/regwrite_EX
add wave /cpu/writeaddr_WB
add wave /cpu/stall_EX
add wave /cpu/shamt_EX
add wave /cpu/A_BP
add wave /cpu/readdata1_EX
add wave /cpu/readdata2_EX
add wave /cpu/myregfile/readdata2
add wave /cpu/lo_WB
add wave /cpu/lo_CD
add wave /cpu/hi_EX
add wave /cpu/hi_old
add wave /cpu/lo_EX
add wave /cpu/lo_old
add wave /cpu/A_EX
add wave /cpu/B_EX
add wave /cpu/zero_EX
add wave /cpu/alu_src_EX
add wave -r /cpu/myalu/*
add wave /cpu/myregfile/mem
# -------------------------------------- #
# ---- This is where testing starts ---- # 
# -------------------------------------- #

# -------------------------------------- #
# - Sequence to push values onto stack - # 
# -------------------------------------- #
force /cpu/rst 0
run 1
force /cpu/rst 1
run 1
force /cpu/rst 0
run 1
run 15000
# ------------------------------------- #




view transcript
view wave
wave zoom full
















