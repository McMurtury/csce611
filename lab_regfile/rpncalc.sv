/* RPN calculator module implementation */

module rpncalc (

/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] rst,		/* reset */
	input [1:0 ] mode,		/* mode from SW17 and SW16 */
	input [3:0 ] key,		/* value from KEYs */

					/* Remember that the 2 bit mode and
					 * 4 bit key value are used to
					 * uniquely identify one of 16
					 * operations. Also keep in mind that
					 * they keys are onehot (i.e. only one
					 * key is pressed at a time -- if
					 * more than one key is pressed at a
					 * time, the behavior is undefined
					 * (i.e. you may choose your own
					 * behavior). */

	input [15:0] val,		/* 16 bit value from SW15...SW0 */

/*
	//Extra to drive regfile.
	input [0:0 ] we,		/* write enable *
	input [4:0 ] readaddr1,		/* read address 1 *
	input [4:0 ] readaddr2,		/* read address 2 *
	input [4:0 ] writeaddr,		/* write address *
	input [31:0] writedata,		/* write data *
*/

/**** outputs ****************************************************************/

	output [15:0] top,		/* 16 bit value at the top of the
					 * stack, to be shown on HEX3...HEX0 */

	output [15:0] next,		/* 16 bit value second-to-top in the
					 * stack, to be shown on HEX7...HEX4 */

	output [7:0] counter		/* counter value to show on LEDG */

);

	logic [5:0] opcode; //decodes the input into a single bit opcode for a case statement. 
	static logic true;
	static logic false;
	//static logic [5:0] counter;
	logic we;
	logic [4:0] readaddr1; 
	logic [4:0] readaddr2;
	logic [4:0] writeaddr;
	logic [31:0] writedata;
	logic [31:0] a;
	logic [31:0] b;
	logic [5:0] op;
	logic [31:0] shamt;
	reg [31:0] hi;
	reg [31:0] lo;
	logic zero;
	integer i;
	logic pop;
	logic push;
	logic [31:0] data_in;
	//logic [31:0] top;
	logic full;
	logic empty;
	logic signal;
	logic [3:0] key_dly;
	logic [3:0] key_dly2;
	static logic [5:0] count;

  typedef enum logic [3:0] {idle,push_only,pop_only,add_op1,sub_op,umult_op,
			    shiftL_op,shiftR_op,comp_op,and1_op,or_op,nor_op,xor_op,reves_op} state_type;
  state_type current_state,next_state;

always_ff @(posedge clk) begin
		opcode <= {mode, key};
end



module stack (input clk,rst,pop,push, input [4:0] readaddr2, input [31:0] data_in,
	output [31:0] stack_top, output [31:0] stack_sec, output full,empty);
	logic [5:0] stack_top_ptr,stack_ptr;
	
	//cnt6 stackctr(.clk(clk),.rst(rst),.en_up(push),.en_down(pop),.cnt(stack_ptr));
	//assign stack_top_ptr = stack_ptr-6'b1;
	assign full = stack_ptr==6'd32 ? 1'd1 : 1'd0;
	assign empty = stack_ptr==6'd0 ? 1'd1 : 1'd0;

	assign stack_top_ptr = readaddr2 + 1;

	/*
	//To do: Adjust the pointer that points to the current top element in the stack.
	always_comb begin
		if (pop) begin
			stack_top_ptr = stack_top_ptr - 1;
			
		end
		else if (push) begin
			stack_top_ptr = stack_top_ptr + 1;
		end
	end //always_comb
	*/

	regfile stackregs(.clk(clk),
			       .rst(rst), 
			       .we(push), 
			       .readaddr1(stack_top_ptr[4:0]),
			       .readaddr2(readaddr2), //5'b0),
			       .writeaddr(stack_ptr[4:0]),
			       .writedata(data_in),
			       .readdata1(stack_top),
			       .readdata2(stack_sec));
endmodule

/* your code here */	
	initial begin
		logic we = 0;
		logic [4:0] readaddr1 = 0; 
		logic [4:0] readaddr2 = 0;
		logic [4:0] writeaddr = 0;
		logic [31:0] writedata = 0;
		//logic [ ] counter = 0;
		logic [31:0] a     = 0;
		logic [31:0] b     = 0;
		logic [5:0] op    = 0;
		logic [31:0] shamt = 0;
		reg [31:0] hi = 0;
		reg [31:0] lo = 0;
		logic zero = 0;
		integer i = 0;
		//logic [ ] error = 0;
		logic pop = 0;
		logic push = 0;
		//stack leStack;
		logic [31:0] data_in = 32'b0;
		logic [31:0] top = 32'b0;
		logic full = 0;
		logic empty = 0;
		static logic true = 1;
		static logic false = 0;
		logic signal = 0;
		//static logic [5:0] counter = 5'b0;
		//logic counter = 5'b0;
		static logic [3:0] key_dly = 0;
		static logic [3:0] key_dly2 = 0;
		static logic [5:0] count = 5'b0;


		//top = 16'b0;
		//next = 16'b0;
		//counter = 8'b0;
	end



	// instantiate the ALU 
	alu dut (a, b, op, shamt, hi, lo, zero);
	stack leStack(.clk(clk),.rst(signal),.pop(pop),.push(push), 
			.readaddr2(readaddr2), .data_in(data_in),
			.stack_top(a), .stack_sec(b), .full(full),.empty(empty));


	//assign top = a;
	//assign next = b;
	//assign counter = count;

/* don't forget to...
 *
 * - instantiate the register file
 * - hard-code readaddr1 to address of the top of the stack
 * - hard-code readaddr2 to the address of the next-to-top of the stack
 *
 */
  always_ff @(posedge clk)begin
    	key_dly = key;
    	key_dly2 = key_dly;
  end
	
always_comb begin
	//static logic [5:0] count = 5'b0;
	  logic en_pop,en_push,key_dly,key_dly2,go;
//  typedef enum logic [3:0] {idle,push_only,pop_only,add_op1,sub_op,umult_op,
//			    shiftL_op,shiftR_op,comp_op,and1_op,or_op,nor_op,xor_op,reves_op} state_type;
//  state_type current_state,next_state;


   
  assign go = &key_dly2 & ~&key_dly;
  
  //always_comb begin
    	//pop = 1'b0;
	//push = 1'b0;
	next_state = idle; //default
	current_state = idle; //init and default
	//if(counter > 1) readaddr2 = readaddr2 + 1;

	case (current_state)

		//idle state
		idle: begin if (go) begin 
			if(mode == 2'b00 && key_dly == 4'b1110) next_state = add_op1;
			if(mode == 2'b00 && key_dly == 4'b1111) next_state = sub_op;
			if(mode == 2'b01 && key_dly == 4'b1100) next_state = umult_op;
			if(mode == 2'b01 && key_dly == 4'b1101) next_state = shiftL_op;
			if(mode == 2'b01 && key_dly == 4'b1110) next_state = shiftR_op;
			if(mode == 2'b01 && key_dly == 4'b1111) next_state = comp_op;
			if(mode == 2'b10 && key_dly == 4'b1100) next_state = and1_op;
			if(mode == 2'b10 && key_dly == 4'b1101) next_state = or_op;
			if(mode == 2'b10 && key_dly == 4'b1110) next_state = nor_op;
			if(mode == 2'b10 && key_dly == 4'b1111) next_state = xor_op;
			if(mode == 2'b11 && key_dly == 4'b1100) next_state = reves_op;
			if(mode == 2'b00 && key_dly == 4'b1100) next_state = push_only;
			if(mode == 2'b00 && key_dly == 4'b1101) next_state = pop_only;
			end
		end

		//Reset No ALU code.
		//6'b11_0000: begin op <= 1010;
		//	signal <= true; 
		//	pop <= false;
		//end

		//leStack(.clk(clk),.rst(1),.pop,.push,input [31:0] data_in,
						//output [31:0] stack_top,output full,empty);
		
		//push No ALU code
		push_only: begin op <= 1010; shamt <= false; pop <= false; push <= true; 
				signal <= false; count = count + 1; end
	
		//pop No ALU code.
		pop_only: begin op <= 1010; shamt <= false;  
				signal <= false; count = count - 1; end
			//signal <= false; 
			//pop <= true; 
			//push <= false; 
			//readaddr2 <= readaddr2 - 1;
	
		// arithmetic operations
		//Add ALU 0100
		add_op1: begin op <= 0100; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1; 
				readaddr2 = count - 1;
				data_in <= lo;
				end
		//Sub ALU 0101
		sub_op: begin op <= 0101; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end
	
		// mult unsigned ALU 0111
		umult_op: begin op <= 0111; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end

		//Pop top 2 and push second shifted left by topmost value ALU 1000
		shiftL_op: begin op <= 1000; shamt <= b; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end

		//Pop top 2 second shifted right (logical) by topmost value ALU 1001
		shiftR_op: begin op <= 1001; shamt <= b; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end

		//pop top 2 compare two, ALU 1100
		comp_op: begin op <= 1100; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end

		//pop top 2 bitwise AND ALU 0000
		and1_op: begin op <= 0000; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end

		//pop top 2 bitwise OR ALU 0001
		or_op: begin op <= 0001; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end

		//pop top 2 bitwise NOR ALU 0010
		nor_op: begin op <= 0010; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end
		//pop top 2 bitwise XOR ALU 0011
		xor_op: begin op <= 0011; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count - 1;  

				end

		//pop top 2 values and push them back on in reverse order.
		reves_op: begin op <= 1010; shamt <= false; signal <= false;
				pop <= true; push <= false; count = count;  

				end

	endcase //Ends the case statement.
end //Always_comb block



//**********************************************************************************

//State machine... Tiamat help me...
/*
module sMachine(input [1:0] mode, [3:0] key);

  logic en_pop,en_push,key_dly,key_dly2,go;
  typedef enum logic [3:0] {idle,push_only,pop_only,pop1_for_op,pop2_for_op,push_for_op,
                            pop1_rev,pop2_rev,push1_rev,push2_rev} state_type;
  state_type current_state,next_state;

  always@(posedge clk)begin
    key_dly = key;
    key_dly2 = key_dly;
  end
   
  assign go = &key_dly2 & ~&key_dly;
  
  always_comb begin
    pop = 1'b0;
    push = 1'b0;

    //The state machine tells the program what state it is in. And what it should be doing.
    //This will define what it is allowed to do.
	
    //TO DO:
    //USE an large if and else if rather than a switch statement.

    next_state = idle; //default
	if(current_state == idle && go && mode == 2'b00 && key_dly == 4'b1101) next_state == add_op1;
	else if(current_state == push_only)
	else if (current_state == pop_only)
	else if (current_state == pop1_for_op)
	else if (current_state == pop2_for_op)
	else if (current_state == push_for_op)
	else if (current_state == pop1__rev)
	else if (current_state == pop2_rev)
	else if (current_state == push1_rev)
	else if (current_state == push2_rev)

  end

endmodule//end of sMachine
*/
endmodule//end of RPNCalc
