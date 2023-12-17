module Imem(input logic [31:0] A, output logic [31:0] RD);
logic [31:0] RAM[2097151:0]; //64 instructions, each has 32 bits 
initial
$readmemh("memfile.dat",RAM); //reads data in file (machine-coded instructions) to RAM
assign RD = RAM[A[22:2]]; // word aligned. As address is incremented by 4, first two bits are not needed
endmodule
