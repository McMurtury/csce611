/* MIPS CPU module implementation */

module cpu (

/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] rst,		/* reset */
	input [31:0] gpio_in,		/* GPIO input */

/**** outputs ****************************************************************/

	output [31:0] gpio_out	/* GPIO output */

);

/* your code here */

	logic [31:0] instruction_memory [4095:0];
	logic [11:0] PC_FETCH;
	logic [31:0] instruction_EX

	initial begin
		$readmemh("program.dat",instruction_memory);
	end

	always_ff @(posedge clk, posedge rst) begin
		if(rst) begin
			PC_FETCH <= 12'b0;
			instruction_EX <= 32'b0;
		end else begin
			instruction_EX <= instruction_memory(PC_FETCH);
			PC_FETCH <= PC_FETCH + 12'b1;
		end
	end

	regfile myregfile (.clk(clk)
			   .we()
			   .readaddr1(instruction_EX[25:21])
			   .readaddr2(instruction_EX[20:16])
			   .writeaddr()
			   .readdata1()
			   .readdata2());
endmodule
