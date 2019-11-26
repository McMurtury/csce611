module CSCE611_ri_testbench(

	input CLOCK_50,

	output [15:0] top,		/* 16 bit value at the top of the
					 * stack, to be shown on HEX3...HEX0 */

	output [15:0] next,		/* 16 bit value second-to-top in the
					 * stack, to be shown on HEX7...HEX4 */

	output [7:0] counter
);

	cpu cp(.clk(clk),.rst(rst),.gpio_in(SW),.gpio_out(gpio_out));	


endmodule

