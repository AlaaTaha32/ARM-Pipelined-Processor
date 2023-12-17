module RegFile(input logic clk, WE3, input logic [3:0] RA1, RA2, WA3,
	       input logic [31:0] WD3, R15, output logic [31:0] RD1, RD2);

logic [31:0] RF[14:0]; 		//Register file, 15 registers (PC is not included), each register has 32 bits

initial
assign RF = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  0, 0, 0};
 
// Writing logic
always_ff @(negedge clk) 	//On second half of the cycle
if(WE3) RF[WA3]<= WD3;		//If write is enabled, third port is written on the falling edge of clk.
 				//Register number is specified by write address input WA3
//---------------------------------------------------------------------------------------------------------

// Reading logic
assign RD1=(RA1==4'b1111)? R15:RF[RA1];
assign RD2=(RA2==4'b1111)? R15:RF[RA2]; 
//If register number is 15, output reads data from R15 (PC+8).
//Else, each output reads data from register number specified by read address inputs RA1 and RA2
//---------------------------------------------------------------------------------------------------------  
endmodule 
