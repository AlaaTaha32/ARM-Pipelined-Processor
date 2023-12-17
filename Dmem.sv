module Dmem(input logic clk, MemWrite, input logic [31:0] ALUResult, WriteData,
	    output logic [31:0] ReadData);
logic [31:0] RAM[2097151:0];
initial
$readmemh("memfile.dat",RAM); 	//reads data in file (machine-coded instructions) to RAM
assign ReadData = RAM[ALUResult[31:2]]; //word aligned, ALU_Result specifies the address
always_ff@(posedge clk)
if(MemWrite) RAM[ALUResult[22:2]] <= WriteData; //write data in memory
endmodule
