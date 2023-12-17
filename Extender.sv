module extender(input logic [1:0] ImmSrc, input logic [23:0] Instr, output logic [31:0] ExtImm);
always_comb
case(ImmSrc)
2'b00: ExtImm = {{24{0}}, Instr[7:0]}; //8-bit unsigned immediate for data-processing
2'b01: ExtImm = {{20{0}}, Instr[11:0]}; //12-bit unsigned immediate for LDR/STR
2'b10: ExtImm = {{6{Instr[23]}}, Instr[23:0], 2'b00}; //24-bit signed immediate multiplied by 4 for 8  
default: ExtImm = 32'bx; //undefined
endcase
endmodule
