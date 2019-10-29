/* 32 x 32 register file implementation */

module regfile (

/**** inputs *****************************************************************/

	input [0:0 ] clk,		/* clock */
	input [0:0 ] rst,		/* reset */
	input [0:0 ] we,		/* write enable */
	input [4:0 ] readaddr1,		/* read address 1 */
	input [4:0 ] readaddr2,		/* read address 2 */
	input [4:0 ] writeaddr,		/* write address */
	input [31:0] writedata,		/* write data */

/**** outputs ****************************************************************/

	output reg [31:0] readdata1,	/* read data 1 */
	output reg [31:0] readdata2		/* read data 2 */
);
integer i;

	/* your code here */
	logic [31:0] mem[31:0];

always @(posedge clk) begin
	if((we)) mem[writeaddr] <=writedata;
end

assign readdata1 = readaddr1 == 5'b0 ? 32'b0:
		   readaddr1 == writeaddr && we ? writedata : 
	           mem[readaddr1];
assign readdata2 = readaddr2 == 5'b0 ? 32'b0 :
		   readaddr2 == writeaddr && we ? writedata :
	           mem[readaddr2];




	
//Write to memory
//always @(posedge clk) begin
//	if (we) mem[writeaddr] <= writedata;
//	readdata1 <= mem[readaddr1];
//	readdata2 <= mem[readaddr2];
//end

//If both readaddr are 0, both readdata return 0
/*
always_ff @(posedge clk) begin
	if (we) begin mem[writeaddr] <= writedata;
		readdata1 <= mem[readaddr1];
		readdata2 <= mem[readaddr2];
	end
	else if(readaddr1 == 0) readdata1 <= 32'b0;
	else assign readdata1 = mem[readaddr1];
	
	if(readaddr2 == 0) readdata2 <= 32'b0;
	else assign readdata2 = mem[readaddr2];

end

always_ff @(posedge clk, posedge rst) begin
	if(rst) begin
		for(i=0; i<32; ++i) begin
			mem[i]<= 32'b0; //resets the mem to 0
		end
	end
end
*/
endmodule
