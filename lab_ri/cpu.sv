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

	//program memory
	logic [31:0] instruction_memory [4095:0];	

	//program counter
	logic [11:0] PC_FETCH;

	//current instruction
	logic [31:0] instruction_EX;

	//alu signals
	logic [31:0] A_EX,B_EX,hi_EX,lo_EX;
	logic [4:0] shamt_EX;
	logic [3:0] op_EX;
	logic zero_EX;

	//writeback signals
	logic regwrite_WB,regwrite_EX;
	logic [4:0] writeaddr_WB;
	logic [31:0] lo_WB;
	
	//regfile signals
	logic rdrt_EX;
	logic [31:0] readdata2;

	//alu signals
	logic [1:0] alu_src_EX;

	//read file
	initial begin
		$readmemh("program.dat", instruction_memory);
	end

	//alu mux
	assign B_EX = alu_src_EX == 2'b0 ? readdata2_EX :
		      alu_src_EX == 2'b1 ?
		      {{16{instruction_EX[15]}},instruction_EX[15:0]} :
		      {16'b0, instruction_EX[15:0]};

	//pc control
	logic [1:0] pc_src_EX;
	logic stall_FETCH,stall_EX;

	//set stall
	always_ff @(posedge clk,posedge rst) begin
		if (rst) stall_EX <= 1'b0; else stall_EX <= stall_FETCH;
	end

	//GPIO control
	logic GPIO_out_en;

	always_ff @(posedge,posedge) begin
		if (rst) gpio_out <= 32'b0; else
			if (GPIO_out_en) gpio_out <= readdata2_EX;
	end

	//fetch stage
	always_ff @(posedge clk, posedge rst) begin
		if(rst) begin
			PC_FETCH <= 12'b0;
			instruction_EX <= 32'b0;
		end else begin
			instruction_EX <= instruction_memory[PC_FETCH];
			PC_FETCH <= pc_src_EX == 2'b0 ? PC_FETCH + 12'b1 : PC_FETCH + instruction_EX[11:0];
		end
	end

	//pipeline register
	always_ff @(posedge clk,posedge rst) begin
		if (rst) begin
			regwrite_WB <= 1'b0;
		end else begin
			regwrite_WB <= regwrite_EX;
			writeaddr_WB <= rdrt_EX == 1'b0 ?  instruction_EX[15:11 : instruction_EX[20:16];
			lo_WB <= lo_EX;
		end
	end

	regfile myregfile (.clk(clk),
			   
			   //execute (decode)
			   .readaddr1(instruction_EX[25:21]),
			   .readaddr2(instruction_EX[20:16]),
			   .readdata1(A_EX),
			   .readdata2(readdata2_EX),

			   //writeback
			   .we(regwrite_WB),
			   .writeaddr(writeaddr_WB),
			   .writedata(lo_WB));

	alu myalu (.a(A_EX),
		   .b(B_EX),
		   .shamt(shamt_EX),
		   .op(op_EX),
		   .lo(lo_EX),
		   .hi(hi_EX),
		   .zero(zero_EX));

	always_comb begin
		alu_src_EX = 2'b0;
		rdrt_EX = 1'b0;
		pc_src_EX = 2'b0;
		stall_FETCH = 1'b0;
		GPIO_out_en = 1'b0;

		//r-type instructions
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
		end /*else if (instruction_EX[5:0] == 6'b000000) begin//sll
			op_EX = 4'b1000;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end else if (instruction_EX[5:0] == 6'b011001) begin//srl
			op_EX = 4'b0111;
			regwrite_EX <= 1'b1;
			shamt_EX <= 5'bXXXXX;
		end  
		*/
		
		//i-types instructions
		else if (instruction_EX[31:26]==6'b001000 ||
			 instruction_EX[31:26]==6'b001001) begin
				op_EX = 4'b1000;
				regwrite_WB = 1'b1;
				alu_src_EX = 2'b1;
		end
	end
endmodule
