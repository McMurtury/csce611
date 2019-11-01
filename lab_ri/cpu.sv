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
		$readmemh("program.dat", instruction_memory);
	end

	always_ff @(posedge clk, posedge rst) begin
		if(rst) begin
			PC_FETCH <= 12'b0;
			instruction_EX <= 32'b0;
			regwrite_WB <= 1'b0;
		end else begin
			instruction_EX <= instruction_memory[PC_FETCH];
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

	alu myalu (.a(A_EX),
		   .b(B_EX),
		   .shamt(shamt_EX),
		   .op(op_EX),
		   .lo(lo_EX),
		   .hi(hi_EX),
		   .zero(zero_EX));

	always_comb begin
		if (instruction_EX[5:0] == 6'b100000) begin //add
			op_EX = 4'b0100;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b100001) begin//addu
			op_EX = 4'b0100;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b100010) begin//sub
			op_EX = 4'b0101;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b100011) begin//subu
			op_EX = 4'b0101;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b011000) begin//mult
			op_EX = 4'b0110;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b011001) begin//multu
			op_EX = 4'b0111;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b100100) begin//and
			op_EX = 4'b0000;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b100101) begin//or
			op_EX = 4'b0001;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b100110) begin//xor
			op_EX = 4'b0011;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b100111) begin//nor
			op_EX = 4'b0010;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		/*end else if (instruction_EX[5:0] == 6'b000000) begin//sll
			op_EX = 4'b1000;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b011001) begin//srl
			op_EX = 4'b0111;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end  
		*/
		end
	end
endmodule
