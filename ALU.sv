module ALU#(parameter n=32)(input logic [n-1:0] a, b, input logic [2:0] Cont, output logic [n-1:0] R, output logic [3:0] flags);
logic neg, zero, carry, over;
// Adder part
logic [n:0] sum;
logic [n-1:0] num, BIC;
assign num= Cont[0]? ~b : b; //ALU_Control least significant bit chooses between addition (0) and subtraction (1)
assign sum= a + num + Cont[0];
assign BIC = a & ~b;
//-----------------------------------------
// Result
always_comb
casex(Cont)
3'b00?: R = sum[n-1:0]; 
3'b010: R = a & b;
3'b011: R = a | b;
3'b100: R = a ^ b;
3'b101: R = BIC;
endcase 
//------------------------------------------
// Flags
assign neg = R[n-1];
assign zero = (R==32'b0);
assign carry = sum[n] & (~Cont[1]);
assign over = ~(a[n-1]^b[n-1]^Cont[0]) & (a[n-1]^sum[n-2]) & (~Cont[1]);
assign flags = {neg, zero, carry, over};
endmodule
