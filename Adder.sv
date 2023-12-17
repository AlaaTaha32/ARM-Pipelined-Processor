module Add#(parameter width=8)(input logic [width-1:0] a, b, output logic [width-1:0] y);
assign y=a+b;
endmodule
