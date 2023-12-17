module Mux3#(parameter w=8)(input logic [w-1:0] a,b,c, input logic [1:0] sel, output logic [w-1:0] y);
always_comb
casex(sel)
2'b00: y=a;
2'b01: y=b;
2'b1x: y=c;
endcase
endmodule
