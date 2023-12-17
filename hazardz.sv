module hazard(input logic clk, reset, input logic Match_1E_M, Match_1E_W, Match_2E_M, Match_2E_W, Match_12D_E,
	      input logic RegWriteM, RegWriteW, input logic BranchTakenE, MemtoRegE, input logic PCWrPendingF, PCSrcW,
	      output logic [1:0] ForwardAE, ForwardBE, output logic StallF, StallD, output logic FlushD, FlushE);

logic ldrStallD;
// Data forwarding logic
always_comb begin
if (Match_1E_M & RegWriteM) ForwardAE = 2'b10;// if we discover matching in the address source (A1) in memory and what's read in the third adress (A3), we forward what's read in the third address in excute (WA3E)
					      //since this operation involves writing into the register file so we require register write control to be enabled
else if (Match_1E_W & RegWriteW) ForwardAE = 2'b01;// here we search for matching in the writeback stage under the same conditions
else ForwardAE = 2'b00; //No data forwarding
						//notice that we search for matcing in the stage right before current, then on the stage before previous, due to the possiblity of the previous changing the one before it
if (Match_2E_M & RegWriteM) ForwardBE = 2'b10;// the same matching test is done but this time for the second address (A2)
else if (Match_2E_W & RegWriteW) ForwardBE = 2'b01;//same as the comment in line 15
else ForwardBE = 2'b00;
end
//----------------------------------------------------------------------------------------------------------------------------------------------------

// Control hazards + LDR hazard
assign ldrStallD = Match_12D_E & MemtoRegE;// we guarentee stalling during LDR by making sure that one of the matchings happened "and" the memory to register writing is enabled
assign StallD = ldrStallD;//we confirm the stall command if LDR stall is confirmed
assign StallF = ldrStallD | PCWrPendingF;// to stall in fetch stage, the LDR stall should be confirmed "or" a command to change the PC is made in stages E,D or M
assign FlushE = ldrStallD | BranchTakenE;//we flush out old values to prevent processing of old values if stall is confirmed or if we are branching
assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;//flush out old values in D stage, in this case, if the command of PC writing is confirmed, or it is the stage for changing the PC input or we are branching
endmodule