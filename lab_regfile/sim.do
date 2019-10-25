#vlog *.sv
#vlog *.sv

restart -f

#restart -f
vlog -novopt *.sv
vsim -novopt work.rpncalc

#add everything
#add wave -r /rpncalc/*

# -------------------------------------- #
# --- Adding wave forms automatically -- # 
# -------------------------------------- #
add wave /rpncalc/shamt
add wave /rpncalc/clk
add wave /rpncalc/rst
add wave /rpncalc/mode
add wave /rpncalc/key
add wave /rpncalc/val

add wave /rpncalc/top
add wave /rpncalc/next
add wave /rpncalc/counter
add wave /rpncalc/pop
add wave /rpncalc/push

add wave /rpncalc/op
add wave /rpncalc/key_dly
add wave /rpncalc/key_dly2
add wave /rpncalc/a
add wave /rpncalc/b






force -freeze sim:/rpncalc/clk 1 0, 0 {50 ns} -r 100

# -------------------------------------- #
# ---- This is where testing starts ---- # 
# -------------------------------------- #

# -------------------------------------- #
# - Sequence to push values onto stack - # 
# -------------------------------------- #
run    
force val 16'hBEEF 
run
force rst 1        
force mode 2'b00   
force key 4'h0111   
run 
force rst 0        
force push 1       
run
#force push 0       
#run
#force key 4'hf    
#run 500    
#force key 4'hf     
#run 300
#force val 16'hDEAD 
#force mode 2'b00   
#force key 4'hf 
#run
#force push 1       
#run
#force push 0       
#run
# This key press corresponds to op input 4'b1110 -> 4'he
#force key 4'b0100                      
#run 500
#force key 4'hf     
#run 300
# ------------------------------------- #




view transcript
view wave
wave zoom full
















