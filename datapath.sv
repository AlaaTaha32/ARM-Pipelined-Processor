module datapath(input logic clk, reset, input logic [1:0] RegSrcD, ImmSrcD, input logic ALUSrcE, BranchTakenE,
		input logic [2:0] ALUControlE, input logic MemtoRegW, PCSrcW, RegWriteW, output logic [31:0] PCF,
		input logic [31:0] InstrF, output logic [31:0] InstrD, output logic [31:0] ALUOutM, WriteDataM,
		input logic [31:0] ReadDataM, output logic [3:0] ALUFlagsE, output logic Match_1E_M, Match_1E_W, Match_2E_M,
		Match_2E_W, Match_12D_E, input logic [1:0] ForwardAE, ForwardBE, input logic StallF, StallD, FlushD);

logic [31:0] PCPlus4F, PCnext1F, PCnextF;
logic [31:0] ExtImmD, rd1D, rd2D, PCPlus8D;
logic [31:0] rd1E, rd2E, ExtImmE, SrcAE, SrcBE, WriteDataE, ALUResultE;
logic [31:0] ReadDataW, ALUOutW, ResultW;
logic [3:0] RA1D, RA2D, RA1E, RA2E, WA3E, WA3M, WA3W;
logic Match_1D_E, Match_2D_E;

// Fetch stage
Mux2 #(32) PC_Mux(PCPlus4F, ResultW, PCSrcW, PCnext1F); // the left-most mux on the fetch stage, responsible for updating the PC
Mux2 #(32) Branch_Mux(PCnext1F, ALUResultE, BranchTakenE, PCnextF); //second to left-most mux, responsible for updating the PC during branching or any changes done on it throughout the datapath
En_Res_FF #(32) PC_Reg(clk, reset, ~StallF, PCnextF, PCF); // FF containing the data registered on PC
Add #(32) PC_Adder(PCF, 32'h4, PCPlus4F); //allows for PC+4 and thereby PC+8
//----------------------------------------------------------------------------------------------------------------------------------------------------

// Decode Stage
assign PCPlus8D = PCPlus4F; // skipping register, and moving to R15
Cl_En_Res_FF #(32) Instr_Reg(clk, reset, ~StallD, FlushD, InstrF, InstrD); //the register block that saves the data output of F stage to take it to D stage
Mux2 #(4) RA1_Mux(InstrD[19:16], 4'b1111, RegSrcD[0], RA1D); //outputs the input onto the first address (A1), either the first source or the PC register (R15)
Mux2 #(4) RA2_Mux(InstrD[3:0], InstrD[15:12], RegSrcD[1], RA2D); //outputs the input onto the second address (A2),the second source is chosen either value or register
RegFile RF(clk, RegWriteW, RA1D, RA2D, WA3W, ResultW, PCPlus8D, rd1D, rd2D); //register file unit on which all register values are stored
extender ext(InstrD[23:0], ImmSrcD, ExtImmD); //extends the values depending on the operation (takes the last 8 bits in Instr for Data-processing;12 bits for memory allocation;24 immmediate for branching)
//----------------------------------------------------------------------------------------------------------------------------------------------------

// Execute Stage
Res_FF #(32) RD1_Reg(clk, reset, rd1D, rd1E); //all the following FF(line 36~41) store the values of different registers in D stage
Res_FF #(32) RD2_Reg(clk, reset, rd2D, rd2E); //and are readied to be processed in E stage
Res_FF #(32) Imm_Reg(clk, reset, ExtImmD, ExtImmE);
Res_FF #(4) WA3E_Reg(clk, reset, InstrD[15:12], WA3E);
Res_FF #(4) RA1_Reg(clk, reset, RA1D, RA1E);
Res_FF #(4) RA2_Reg(clk, reset, RA2D, RA2E);
Mux3 #(32) byp1_Mux(rd1E, ResultW, ALUOutM, ForwardAE, SrcAE); //selector mux for the first source, either processed data from D stage, results form write back stage or output from the alu following it
Mux3 #(32) byp2_Mux(rd2E, ResultW, ALUOutM, ForwardBE, WriteDataE); //similar case but it chooses for the second source, either processed data from the D stage,
 								    //output from the following alu or write data in the E stage both the previous muxes forward their outputs 
Mux2 #(32) srcB_Mux(WriteDataE, ExtImmE, ALUSrcE, SrcBE); //chooses from extended immediate value or data choses by mux "byp2_Mux"
ALU alu(SrcAE, SrcBE, ALUControlE, ALUResultE, ALUFlagsE); //operates on the data chosen by the two previous muxes "byp1_Mux" and "byp2_Mux"
//-----------------------------------------------------------------------------------------------------------------------------------------------------

// Memory Stage
Res_FF #(32) Alu_Result_Reg(clk, reset, ALUResultE, ALUOutM); //saves alu outcome from the previous E stage
Res_FF #(32) WD_Reg(clk, reset, WriteDataE, WriteDataM); //saves write data selected from "byp2_Mux" in E stage
Res_FF #(4) WA3m_Reg(clk, reset, WA3E, WA3M); //forwarded data from E stage
//----------------------------------------------------------------------------------------------------------------------------------------------------

// Writeback Stage
Res_FF #(32) Alu_Out_Reg(clk, reset, ALUOutM, ALUOutW);
Res_FF #(32) RD_Reg(clk, reset, ReadDataM, ReadDataW);
Res_FF #(4) WA3w_Reg(clk, reset, WA3M, WA3W); //forwarded data from M stage
Mux2 #(32) Res_Mux(ALUOutW, ReadDataW, MemtoRegW, ResultW); //chooses, depending on trajectory, the incoming data
//----------------------------------------------------------------------------------------------------------------------------------------------------

// hazard comparison
Eq_Comp #(4) cmp0(WA3M, RA1E, Match_1E_M); //comparing data of first source in E and M stages(compare to previous)
Eq_Comp #(4) cmp1(WA3W, RA1E, Match_1E_W); //comparing data of first source in E and W stages(compare to prior to previous)
Eq_Comp #(4) cmp2(WA3M, RA2E, Match_2E_M); //comparing data of second source in E and M stages(compare to previous)
Eq_Comp #(4) cmp3(WA3W, RA2E, Match_2E_W); //comparing data of second source in E and M stages(compare to prior to previous)
Eq_Comp #(4) cmp4a(WA3E, RA1D, Match_1D_E); //comparing forwarded data and first source
Eq_Comp #(4) cmp4b(WA3E, RA2D, Match_2D_E); //comparing forwarded data and second source
assign Match_12D_E = Match_1D_E | Match_2D_E; //asserting the existence of a match in data
endmodule
