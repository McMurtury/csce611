/* MIPS CPU module implementation */

module cpu (

/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] rst,		/* reset */
	input [31:0] gpio_in,		/* GPIO input */

/**** outputs ****************************************************************/

	output logic [31:0] gpio_out	/* GPIO output */

);

/* your code here */

	//program memory
	logic [31:0] instruction_memory [4095:0];	

	//program counter
	logic [11:0] PC_FETCH;

	//current instruction
	logic [31:0] instruction_EX;

	//alu signals
	logic [31:0] A_EX,B_EX,hi_EX,lo_EX, hi_old, lo_old;
	logic [4:0] shamt_EX;
	logic [3:0] op_EX;
	logic zero_EX;

	//writeback signals
	logic regwrite_WB,regwrite_EX;
	logic [4:0] writeaddr_WB;
	logic [31:0] lo_WB;
	
	//regfile signals
	logic rdrt_EX;
	logic [1:0] lo_CD;
	logic [31:0] readdata2_EX, readdata1_EX;

	//alu signals
	logic [1:0] alu_src_EX;
	logic A_BP;

	//read file
	initial begin
		$readmemh("test.dat", instruction_memory);
	end

	//alu mux
	/*always_comb begin
		if (alu_src_EX == 2'b0) B_EX <= readdata2_EX;
		else if (alu_src_EX == 2'b1) B_EX <= {{16{instruction_EX[15]}},instruction_EX[15:0]};
		else B_EX <= {16'b0, instruction_EX[15:0]};
	end*/
	assign B_EX = alu_src_EX == 2'b0 ? readdata2_EX :
		      alu_src_EX == 2'b1 ? {{16{instruction_EX[15]}},instruction_EX[15:0]} :
		      alu_src_EX == 2'b10 ? lo_WB :
		      {16'b0, instruction_EX[15:0]};
	

	//A bypass mux
	assign A_EX = A_BP == 1'b1 ? lo_WB : readdata1_EX;

	//pc control
	logic [1:0] pc_src_EX;
	logic stall_FETCH,stall_EX;

	//set stall
	always_ff @(posedge clk,posedge rst) begin
		if (rst) stall_EX <= 1'b0; else stall_EX <= stall_FETCH;
	end

	//GPIO control
	logic GPIO_out_en;

	always_ff @(posedge clk,posedge rst) begin
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
			if(instruction_EX[5:0] == 6'b011001 || instruction_EX[5:0] == 6'b011000) hi_old <= hi_EX;
			if(instruction_EX[5:0] == 6'b011001 || instruction_EX[5:0] == 6'b011000) lo_old <= lo_EX;
			PC_FETCH <= pc_src_EX == 2'b0 ? PC_FETCH + 12'b1 : 
				PC_FETCH + instruction_EX[11:0];
		end
	end

	//pipeline register
	always_ff @(posedge clk,posedge rst) begin
		if (rst) begin
			regwrite_WB <= 1'b0;
		end else begin
			regwrite_WB <= regwrite_EX;
			/*if (rdrt_EX == 1'b0) writeaddr_WB <= instruction_EX[15:11];
			else if (rdrt_EX == 1'b1) writeaddr_WB <= instruction_EX[20:16];*/
			writeaddr_WB <= rdrt_EX == 1'b0 ?  instruction_EX[15:11] : instruction_EX[20:16];
		end
	end

	//for lo_EX
	always_ff @(posedge clk,posedge rst) begin
			if(lo_CD == 2'b0) lo_WB <= lo_EX; //<=
			else if (lo_CD == 2'b1) lo_WB <= hi_EX; //<=
			else if (lo_CD == 2'b10) lo_WB <= lo_old;
			else if (lo_CD == 2'b11) lo_WB <= hi_old;
	end

	regfile myregfile (.clk(clk),
			   
			   //execute (decode)
			   .readaddr1(instruction_EX[25:21]),
			   .readaddr2(instruction_EX[20:16]),
			   .readdata1(readdata1_EX),
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
		op_EX = 4'b0100;
		shamt_EX = 5'bXXXXX;
		lo_CD = 2'b0;
		A_BP = 1'd0;
		if(rst == 1) regwrite_EX = 1'b0;

		if(~stall_EX) begin
			if(instruction_EX[31:26] == 6'b0) begin
				//r-type instructions
				if (instruction_EX[5:0] == 6'b100000 || 
					instruction_EX[5:0] == 6'b100001) begin //add, addu
					regwrite_EX = 1'b1;
					//rdrt_EX = 1'b1;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b100010 ||
						instruction_EX[5:0] == 6'b100011) begin//sub, subu
					op_EX = 4'b0101;
					regwrite_EX = 1'b1;
					//rdrt_EX = 1'b1;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b011000) begin//mult
					op_EX = 4'b0110;
					regwrite_EX = 1'b0;
					rdrt_EX = 1'b1;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b011001) begin//multu
					op_EX = 4'b0111;
					regwrite_EX = 1'b0;
					rdrt_EX = 1'b1;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b100100) begin//and
					op_EX = 4'b0000;
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b100101) begin//or
					op_EX = 4'b0001;
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b100110) begin//xor
					op_EX = 4'b0011;
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b100111) begin//nor
					op_EX = 4'b0010;
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b000000) begin//sll
					op_EX = 4'b1000;
					regwrite_EX = 1'b1;
					shamt_EX = instruction_EX[10:6];
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b000010) begin//srl
					op_EX = 4'b1001;
					regwrite_EX = 1'b1;
					shamt_EX = instruction_EX[10:6];
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b000011) begin//sra
					op_EX = 4'b1011;
					regwrite_EX = 1'b1;
					shamt_EX = instruction_EX[10:6];
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b101010) begin//slt
					op_EX = 4'b1100;
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b101011) begin//sltu
					op_EX = 4'b1111;
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b010000) begin//mfhi
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					lo_CD = 2'b11;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[5:0] == 6'b010010) begin//mflo
					regwrite_EX = 1'b1;
					rdrt_EX = 1'b0;
					lo_CD = 2'b10;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

				end else if (instruction_EX[31:0] == 32'b0) begin//nop
					stall_FETCH = 1;
					regwrite_EX = 1'b0;
					if (instruction_EX[20:16] == writeaddr_WB) alu_src_EX = 2'b10;
					if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;
				end 

			//i-types instructions
			//addi, addiu			
/*end of if state*/	end else if (instruction_EX[31:26]==6'b001000 ||
				 instruction_EX[31:26]==6'b001001) begin
					
					regwrite_EX = 1'b1;
					alu_src_EX = 2'b11;
					rdrt_EX = 1'b1;
			//lui
			end else if (instruction_EX[31:26]==6'b001111) begin
					op_EX = 4'b1000;
					regwrite_EX = 1'b1;
					alu_src_EX = 2'b1;
					shamt_EX = 5'd16; //sll
					rdrt_EX = 1'b1;
			//ori
			end else if (instruction_EX[31:26]==6'b001101) begin
					op_EX = 4'b0001;
					regwrite_EX = 1'b1;
					alu_src_EX = 2'b11;
					rdrt_EX = 1'b1;
			//bne
			end else if (instruction_EX[31:26]==6'b000101) begin
					op_EX = 4'b0101; // sub
					regwrite_EX = 1'b0;
					if (~zero_EX) begin
						stall_FETCH = 1'b1;
						pc_src_EX = 2'b1;
					end
			//srl (gpio write)
			end else if (instruction_EX[31:26]==6'b0 &&
						instruction_EX[5:0]==6'b000010 &&
						instruction_EX[10:6]==5'b0) begin
						GPIO_out_en = 1'b1;
						regwrite_EX = 1'b0;

			end else if (instruction_EX[31:26] == 6'b001100) begin//andi
				op_EX = 4'b0000;
				alu_src_EX = 2'b11;
				regwrite_EX = 1'b1;
				rdrt_EX = 1'b1;
				if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

			end else if (instruction_EX[31:26] == 6'b001110) begin//xori
				op_EX = 4'b0011;
				alu_src_EX = 2'b11;
				regwrite_EX = 1'b1;
				rdrt_EX = 1'b1;
				if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

			end else if (instruction_EX[31:26] == 6'b001010) begin//slti
				op_EX = 4'b1100;
				alu_src_EX = 2'b11;
				regwrite_EX = 1'b1;
				rdrt_EX = 1'b1;
				if (instruction_EX[25:21] == writeaddr_WB) A_BP = 1'd1;

			end
		end
	end

endmodule
