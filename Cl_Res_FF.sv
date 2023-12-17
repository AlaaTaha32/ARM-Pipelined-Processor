module Cl_Res_FF#(parameter width =8)(input logic clk, res, clr, input logic [width-1:0] D, output logic [width-1:0] Q);
//asynchronous reset, multiple clocks
always_ff @(posedge clk, posedge res)
if(res) Q<=0;
else
if(clr) Q<=0;
else Q<=D;
endmodule 