module Cl_En_Res_FF#(parameter width =8)(input logic clk, res, en, clr, input logic [width-1:0] D, output logic [width-1:0] Q);
//asynchronous reset
always_ff @(posedge clk, posedge res)
if(res) Q<=0;
else if(en)
if(clr) Q<=0;
else Q<=D;
endmodule 