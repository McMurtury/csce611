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

add wave /cpu/clk
add wave /cpu/rst
add wave /cpu/op_EX
add wave /cpu/writeaddr_WB
add wave /cpu/A_EX
add wave /cpu/B_EX
add wave /cpu/PC_FETCH
add wave /cpu/hi_EX
add wave /cpu/lo_EX

force -freeze sim:/cpu/clk 1 0, 0 {50 ns} -r 100

# -------------------------------------- #
# ---- This is where testing starts ---- # 
# -------------------------------------- #

# -------------------------------------- #
# - Sequence to push values onto stack - # 
# -------------------------------------- #
force rst 1
run
force rst 0
run
run 3000
#force val 16'hBEEF 
# ------------------------------------- #




view transcript
view wave
wave zoom full
















