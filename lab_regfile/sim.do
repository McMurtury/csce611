#vlog *.sv
#vlog *.sv

#restart -f

#restart -f
vlog -novopt *.sv
vsim -novopt work.rpncalc

#add everything
#add wave -r /rpncalc/*

# -------------------------------------- #
# --- Adding wave forms automatically -- # 
# -------------------------------------- #
#add wave /rpncalc/shamt
add wave /rpncalc/clk
add wave /rpncalc/rst
add wave /rpncalc/mode
add wave /rpncalc/key
add wave /rpncalc/val
add wave /rpncalc/results
add wave /rpncalc/results_stall
add wave /rpncalc/readdata1
add wave /rpncalc/readdata2

add wave /rpncalc/top
add wave /rpncalc/next
add wave /rpncalc/count
add wave /rpncalc/last
add wave /rpncalc/counter


add wave /rpncalc/op_code
add wave /rpncalc/key_dly
add wave /rpncalc/key2_dly

add wave /rpncalc/current_state
add wave /rpncalc/next_state
add wave /rpncalc/go

add wave /rpncalc/memory/mem


force -freeze sim:/rpncalc/clk 1 0, 0 {50 ns} -r 100

# -------------------------------------- #
# ---- This is where testing starts ---- # 
# -------------------------------------- #

# -------------------------------------- #
# - Sequence to push values onto stack - # 
# -------------------------------------- #
run    
force val 16'h5 
force key 4'hf
run
force rst 0
run
force rst 1
run
force rst 0
run

#pushes values to sim
force mode 2'b00
run
run 
force key 4'hf
run
force key 4'b11
run
run
force key 4'hf
run
force val 16'h2
run
force key 4'b11
run
run
force key 4'hf
force val 16'h3
run
run
force key 4'b11
run
force key 4'hf
force val 16'h4
run
run
force key 4'b11
run
force key 4'hf
force val 16'h6
run
force key 4'b11
run 
force key 4'hf
force val 16'h2
run
#second set of val
force key 4'hf
run
force val 16'h2
run
force key 4'b11
run
run
force key 4'hf
force val 16'h3
run
run
force key 4'b11
run
force key 4'hf
force val 16'h4
run
run
force key 4'b11
run
force key 4'hf
force val 16'h6
run
force key 4'b11
run 
force key 4'hf
force val 16'h2
run

#third set of val
force key 4'hf
run
force val 16'h2
run
force key 4'b11
run
run
force key 4'hf
force val 16'h3
run
run
force key 4'b11
run
force key 4'hf
force val 16'h4
run
run
force key 4'b11
run
force key 4'hf
force val 16'h6
run
force key 4'b11
run 
force key 4'hf
force val 16'h2
run

run
run

#runs the operations
force mode 2'b10
run
#force key 4'b0
run
force key 4'hf
run
run
run
force key 4'b1
run
force key 4'hf
run
run
run
force key 4'b10
run
force key 4'hf
run
run
run
force key 4'b11
run
force key 4'hf
run
run
run
force key 4'b0
run
run
run

force mode 2'b00
run
#force key 4'b0
run
force key 4'hf
run
run
run
force key 4'b1
run
force key 4'hf
run
run
run
force key 4'b10
run
force key 4'hf
run
run
run
force key 4'b11
run
force key 4'hf
run
run
run
force key 4'b0
run
run
run

force mode 2'b01
run
#force key 4'b0
run
force key 4'hf
run
run
run
force key 4'b1
run
force key 4'hf
run
run
run
force key 4'b10
run
force key 4'hf
run
run
run
force key 4'b11
run
force key 4'hf
run
run
run
force key 4'b0
run
run
run

force mode 2'b11
run
force key 4'b11
run
force key 4'hf
run
force mode 2'b01
run
force key 4'b0
run
run
run

run
run
run



#force val 16'hDEAD 
# This key press corresponds to op input 4'b1110 -> 4'he
#force key 4'b0100                      
#run 500
#force key 4'hf     
#run 300
# ------------------------------------- #




view transcript
view wave
wave zoom full
















