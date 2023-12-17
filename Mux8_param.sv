module Mux2#(parameter width=8)(input logic [width-1:0] a,b , input logic sel, output logic [width-1:0] y);
always_comb
case(sel)
1'b0: y=a;
1'b1: y=b;
endcase
endmodule
