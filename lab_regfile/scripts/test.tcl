# CSCE611 regfile Lab test script
echo "==== CSCE611 regfile LabTest Script ==============================================="
echo ""
echo "TIP: you can run this test again without re-starting modelsim using the command"
echo "do scripts/test.tcl"
echo ""
echo "------ Compile Verilog Files --------------------------------------------------"
vlog -novopt *.sv
echo "------ Load Design ------------------------------------------------------------"
vsim -novopt work.CSCE611_regfile_testbench
echo "------ Setup Waves ------------------------------------------------------------"
add wave -r /CSCE611_regfile_testbench/*
echo "------ Simulate ---------------------------------------------------------------"
run 50000
# make sure the transcript window is visible
view transcript
# bring waves to foreground
view wave
wave zoom full

echo "------ Done -------------------------------------------------------------------"
echo "Design compiled and simulated successfully! (hint: this does not mean"
echo "your design is functionally correct, only that it is syntactically "
echo "valid Verilog)."
echo ""
echo "HINT: you can run the simulation again without restarting modelsim using the"
echo "following command:"
echo ""
echo "do ./scripts/test.tcl"
