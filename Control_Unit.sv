module Control_Unit(input logic clk, reset, input logic [31:12] InstrD, input logic [3:0] ALUFlagsE, 
		    output logic [1:0] RegSrcD, ImmSrcD, output logic ALUSrcE, BranchTakenE, 
 		    output logic [2:0] ALUControlE, output logic MemWriteM, output logic MemtoRegW, PCSrcW, RegWriteW, 
		    output logic RegWriteM, MemtoRegE, output logic PCWrPendingF, input logic FlushE); 
 
logic [9:0] controlsD; 
logic CondExE, ALUOpD; 
logic [2:0] ALUControlD; // 3 bits for 6 operations (EOR and BIC included)
logic ALUSrcD; 
logic MemtoRegD, MemtoRegM; 
logic RegWriteD, RegWriteE, RegWriteGatedE;
logic MemWriteD, MemWriteE, MemWriteGatedE;
logic BranchD, BranchE; 
logic [1:0] FlagWriteD, FlagWriteE; 
logic PCSrcD, PCSrcE, PCSrcM; 
logic [3:0] FlagsE, FlagsNextE, CondE; 
 
// Decode stage 
// Main Decoder 
always_comb 
casex(InstrD[27:26]) 
2'b00: if (InstrD[25]) controlsD = 10'b0000101001; // DP imm 
else controlsD = 10'b0000001001; // DP reg 
2'b01: if (InstrD[20]) controlsD = 10'b0001111000; // LDR 
else controlsD = 10'b1001110100; // STR 
2'b10: controlsD = 10'b0110100010; // B  default: controlsD = 10'bx; // unimplemented 
endcase 
assign {RegSrcD, ImmSrcD, ALUSrcD, MemtoRegD, RegWriteD, MemWriteD, BranchD, ALUOpD} = controlsD; 
//---------------------------------------------------------------------------------------------------------------------

// ALU Decoder
always_comb 
if (ALUOpD) begin // which Data-processing Instr? 
case(InstrD[24:21]) 
4'b0100: ALUControlD = 3'b000; // ADD 
4'b0010: ALUControlD = 3'b001; // SUB 
4'b0000: ALUControlD = 3'b010; // AND 
4'b1100: ALUControlD = 3'b011; // ORR
4'b0001: ALUControlD = 3'b100; // EOR
4'b1110: ALUControlD = 3'b101; // BIC 
default: ALUControlD = 2'bx; // unimplemented 
endcase 
// update flags if S bit is set (C & V only for logic operation)
FlagWriteD[1] = InstrD[20];  
FlagWriteD[0] = InstrD[20] & (ALUControlD == 2'b00 | ALUControlD == 2'b01); 
end else begin 
ALUControlD = 3'b000; // add for non-DP instructions 
FlagWriteD = 2'b00; // don't update Flags 
end 
//-----------------------------------------------------------------------------------------------------------

// PC Logic
assign PCSrcD = (((InstrD[15:12] == 4'b1111) & RegWriteD) | BranchD); 
 
// Execute stage 
Cl_Res_FF #(7) D_E(clk, reset, FlushE, {FlagWriteD, BranchD, MemWriteD, RegWriteD, PCSrcD, MemtoRegD}, 
{FlagWriteE, BranchE, MemWriteE, RegWriteE, PCSrcE, MemtoRegE}); 
Res_FF #(4) D_E_ALU(clk, reset, {ALUSrcD, ALUControlD},{ALUSrcE, ALUControlE}); 
Res_FF #(4) D_E_Cond(clk, reset, InstrD[31:28], CondE); 
Res_FF #(4) D_E_Flags(clk, reset, FlagsNextE, FlagsE); 
// write and Branch controls are conditional 
Cond_Unit Cond(CondE, FlagsE, ALUFlagsE, FlagWriteE, FlagsNextE, CondExE); 
assign BranchTakenE = BranchE & CondExE; 
assign RegWriteGatedE = RegWriteE & CondExE; 
assign MemWriteGatedE = MemWriteE & CondExE; 
assign PCSrcGatedE = PCSrcE & CondExE; 
 
// Memory stage 
Res_FF #(4) E_M(clk, reset, {MemWriteGatedE, MemtoRegE, RegWriteGatedE, PCSrcGatedE}, 
 {MemWriteM, MemtoRegM, RegWriteM, PCSrcM}); 
// Writeback stage 
Res_FF #(3) M_W(clk, reset, {MemtoRegM, RegWriteM, PCSrcM}, 
{MemtoRegW, RegWriteW, PCSrcW});
 
// Hazard Prediction 
assign PCWrPendingF = PCSrcD | PCSrcE | PCSrcM; //Stalls the fetching for 3 cycles till new PC address can be fetched
endmodule
