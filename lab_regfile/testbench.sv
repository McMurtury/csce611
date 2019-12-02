module CSCE611_regfile_testbench(

	input CLOCK_50,

	output [15:0] top,		/* 16 bit value at the top of the
					 * stack, to be shown on HEX3...HEX0 */

	output [15:0] next,		/* 16 bit value second-to-top in the
					 * stack, to be shown on HEX7...HEX4 */

	output [7:0] counter
);
	/*logic [1:0] mode;
	logic [3:0] key;
	logic rst;
	logic [15:0] val;

	initial begin
		mode = 2'b00;
		key = 4'b1100;
		rst = 0;
		val = 16'b1;
	end

	rpncalc test(.clk(clk), .rst(rst), .mode(mode), .key(key), .val(val), .top(top), .next(next), .counter(counter));
	
*/

endmodule
/*
module CSCE611_alu_testbench;

	logic [31:0] a, b;
	logic [3 :0] op;
	logic [4 :0] shamt;

	// actual values
	logic[31:0] hi, lo;
	logic[0 :0] zero;

	// expected values
	logic[31:0] hi_e, lo_e;
	logic[0 :0] zero_e;

	logic [147:0] vectors [999:0]; // 1e3 148 bit test vectors
	logic [147:0] current; // current test vector
	logic [31:0] i; //vector subscript
	logic [3:0] enable; // test vector enable
	logic [31:0] error; // error counter

	initial begin
		a     = 0;
		b     = 0;
		op    = 0;
		shamt = 0;
		i     = 0;
		error = 0;
	end

	* instantiate the ALU we plan to test 
	alu dut (a, b, op, shamt, hi, lo, zero);

	initial begin
		// load test vectors from disk
		// TODO
		$readmemh("vectors.dat", vectors);

		for (i = 0; i < 1000; i = i + 1) begin

			current = vectors[i];

			/* pull out enable, a, b, ... signals to stimulate the
			 * ALU 
			// TODO
			//{enable, a, b, shamt, op, hi_e, lo_e, zero_e} = current;
			enable = current [147:144];
			a = current [143:112];
			b = current [111:80];
			shamt = current [79:72];
			op = current [71:68];
			hi_e = current [67:36];
			lo_e = current [35:4];
			zero_e = current [1:0];

			// check to see if this test vector is unused
			if (enable == 4'b1111) begin

				/* give the ALU time to respond 
				#1;

				// check the result
				// TODO
				if(hi_e !== hi) begin
					error = error + 1;
				$display("Error in hi with Test vector ", i);
				$display("True hi value ", hi);
				$display("Expected hi value ", hi_e);
				end

				if(lo_e !== lo) begin
					error = error + 1;
				$display("Error in lo with Test vector ", i);
				$display("True lo value ", lo);
				$display("Expected lo value ", lo_e);
				end

				if(zero_e !== zero) begin
					error = error + 1;
				$display("Error in zero with Test vector ", i);
				$display("True zero value ", zero);
				$display("Expected zero value ", zero_e);
				end

			end // if (current[3:0] 4'b1111) begin

		end // for (i = 0; i < 1000; i++) begin

		$display("Number of Errors ", error);
		
		// tell the simulator we're done
		$stop();

	end // initial begin

endmodule*/
