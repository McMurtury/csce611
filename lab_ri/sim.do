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

add wave -r /*

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
run 1000
# ------------------------------------- #




view transcript
view wave
wave zoom full
















