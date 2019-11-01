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
	logic [31:0] instruction_EX;
	logic [31:0] A_EX,B_EX,hi_EX,lo_EX,lo_WB;
	logic [4:0] shamt_EX;
	logic [3:0] op_EX;
	logic [5:0] writeaddr_WB;
	logic zero_EX,regwrite_WB,regwrite_EX;

	initial begin
		$readmemh("program.dat",instruction_memory);
	end

	always_ff @(posedge clk, posedge rst) begin
		if(rst) begin
			PC_FETCH <= 12'b0;
			instruction_EX <= 32'b0;
			regwrite_WB <= 1'b0;
		end else begin
			instruction_EX <= instruction_memory(PC_FETCH);
			PC_FETCH <= PC_FETCH + 12'b1;
			regwrite_WB <= regwrite_EX;
			writeaddr_WB <= instruction_EX[15:11];
			lo_WB <= lo_EX;
		end
	end

	regfile myregfile (.clk(clk),
			   .we(regwrite_WB),
			   .readaddr1(instruction_EX[25:21]),
			   .readaddr2(instruction_EX[20:16]),
			   .writeaddr(writeaddr_WB),
			   .writedata(lo_WB),
			   .readdata1(A_EX),
			   .readdata2(B_EX));

	alu myalu (.A(A_EX),
		   .B(B_EX),
		   .shamt(shamt_EX),
		   .op(op_EX),
		   .lo(lo_EX),
		   .hi(hi_EX),
		   .zero(zero_EX));

	always_comb begin
		if (instruction_EX[5:0] == 6'b100000) begin
			op_EX = 4'b0100;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end
	end
endmodule
