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

/**** outputs ****************************************************************/

	output [15:0] top,		/* 16 bit value at the top of the
					 * stack, to be shown on HEX3...HEX0 */

	output [15:0] next,		/* 16 bit value second-to-top in the
					 * stack, to be shown on HEX7...HEX4 */

	output [7:0] counter		/* counter value to show on LEDG */

);

/* your code here */

/* don't forget to...
 *
 * - instantiate the register file
 * - hard-code readaddr1 to address of the top of the stack
 * - hard-code readaddr2 to the address of the next-to-top of the stack
 *
 */
	//Counter
	static logic [7:0] count, last, last_sec;

	//Logic signal for counting control
	logic [1:0] count_EN;

	//key delays and op code
	logic [3:0] key_dly, key2_dly, op_code;

	//data
	logic [31:0] readdata1, readdata2, results, results_stall, results_stall_two, data;

	//Signals for data mux for writing and the value to write back. 
	logic push_by, regwrite_WB, regwrite_EX, go;

	//States for state machine.
	typedef enum logic [4:0] {
	reset, idle, pop, push, add_op, or_op, mult_op, nor_op, xor_op,
	reves_op, sub_op, umult_op, shiftL_op, shiftR_op, comp_op,
	and_op, stall, stall_two, stall_three, stall_four
	} state_type;

	static state_type current_state, next_state;

	//Memory for the stack.
	regfile memory (.clk(clk),
			   //execute (decode)
			   .readaddr1(last),
			   .readaddr2(last_sec),
			   .readdata1(readdata1),
			   .readdata2(readdata2),

			   //writeback
			   .we(regwrite_WB),
			   .writeaddr(count),
			   .writedata(data));

	//The alu
	alu myalu (.a(readdata1),
		   .b(readdata2),
		   .shamt(readdata1),
		   .op(op_code),
		   .lo(results),
		   .hi(hi),
		   .zero(zero));


	//Updating the address of the second to top element.
	assign last = count == 8'b1111_1111 ? 8'b0 : 
			count == 8'b0 ? 8'b0 :
			count == 8'b1 ? 8'b1 : count - 1;
	assign last_sec = last == 8'b1111_1111 ? 8'b0 : 
			last == 8'b0 ? 8'b0 : last - 1;	
	
	//Outputs the count to the counter.
	assign counter = count - 1;

	//mux for the value to be push to the stack.
	assign data = push_by == 1'b1 ? val : results_stall;

	//go signal to detect user input
	assign go = key2_dly != 4'b1111 ? 1'b0 : 
		    key_dly != key2_dly ? 1'b1 :
			1'b0;

	//Updating the states
	always_ff @(posedge clk, posedge rst) begin
		key2_dly = key_dly;		
		key_dly = key;
		
		if(rst) begin 
			current_state = reset;
			count = 1;
		end else begin
			current_state = next_state;
			if(count_EN == 2'b1) count = count + 1;
			else if(count_EN == 2'b10) count = count - 1;
			else if(count_EN == 2'b11) count = count - 2;
			//regwrite_EX = regwrite_WB;
		end
	end



	//The state machine in the always comb block.
	always_comb begin

		//default signals
		push_by = 1'b0;
		count_EN = 2'b0;
		op_code = 4'b1111;
		regwrite_WB = 1'b0;
		
		//idle state
		if(current_state == idle) begin
			count_EN = 2'b0;
			if (go == 1) begin
				if (mode == 2'b00) begin
					if (key == 4'b1) next_state = add_op;
					else if (key == 4'b10) next_state = pop;
					else if (key == 4'b11) next_state = push;
					else if (key == 4'b0) next_state = sub_op;
				end else if (mode == 2'b01) begin
					if (key == 4'b0) next_state = comp_op;
					else if (key == 4'b1) next_state = shiftR_op;
					else if (key == 4'b10) next_state = shiftL_op;
					else if (key == 4'b11) next_state = umult_op;
				end else if (mode == 2'b10) begin
					if (key == 4'b0) next_state = xor_op;
					else if (key == 4'b1) next_state = nor_op;
					else if (key == 4'b10) next_state = or_op;
					else if (key == 4'b11) next_state = and_op;
				end else if (mode == 2'b11) begin
					if (key == 4'b0) next_state = idle;
					else if (key == 4'b1) next_state = idle;
					else if (key == 4'b10) next_state = idle;
					else if (key == 4'b11) next_state = reves_op;
				end
			end
				
		end else if (current_state == pop) begin //pop
			if (count >= 0) count_EN = 2'b10;
			next_state = idle;
		end else if (current_state == push) begin //push
			count_EN = 2'b1;
			push_by = 1'b1;
			regwrite_WB = 1'b1;
			next_state = idle;
		end else if (current_state == add_op) begin //add
			op_code = 4'b0100;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == or_op) begin //or
			op_code = 4'b00_01;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == mult_op) begin //mult
			op_code = 4'b01_10;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == nor_op) begin //nor
			op_code = 4'b00_10;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == xor_op) begin //xor
			op_code = 4'b00_11;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == reves_op) begin //reverse
			results_stall = readdata1;
			results_stall_two = readdata2;
			count_EN = 2'b11;
			next_state = stall_two;
		end else if (current_state == sub_op) begin // sub
			op_code = 4'b01_01;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == umult_op) begin //unsigned mult
			op_code = 4'b01_11;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == shiftL_op) begin //sll
			op_code = 4'b1000;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == shiftR_op) begin //srl
			op_code = 4'b1001;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == comp_op) begin //compare
			op_code = 4'b11_00;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == and_op) begin //and
			op_code = 4'b00_00;
			count_EN = 2'b11;
			results_stall = results;
			next_state = stall;
		end else if (current_state == reset) begin //rst
			next_state = idle;
		end else if (current_state == stall) begin //stall
			regwrite_WB = 1'b1;
			push_by = 1'b0;
			next_state = stall_four;
		end else if (current_state == stall_two) begin //stall2
			regwrite_WB = 1'b1;
			push_by = 1'b0;
			count_EN = 2'b1;
			//results_stall = results_stall_two;
			next_state = stall_three;
		end else if (current_state == stall_three) begin //stall3
			regwrite_WB = 1'b1;
			push_by = 1'b0;
			next_state = idle;
			results_stall = results_stall_two;
			count_EN = 2'b1;
		end else if (current_state == stall_four) begin //stall4
			next_state = idle;
			count_EN = 2'b1;
		end

	end


endmodule
