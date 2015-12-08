module LSU(CLK, N_RST, LSU_OP, D, O, DA, DD, DE, DQ, WA2, WD2, WE2, JA2, JREQ2, IOA, IOD, IOQ, IOE);
	input CLK, N_RST;
	
	input [5:0] LSU_OP;
	
	input [31:0] D, O;
	
	output [10:0] DA;
	output DE;
	output [31:0] DD;
	input [31:0] DQ;
	
	output [2:0] WA2;
	output [31:0] WD2;
	output WE2;
	
	output [10:0] JA2;
	output JREQ2;
	
	output [3:0] IOA;
	output [31:0] IOD;
	input [31:0] IOQ;
	output IOE;

	reg [4:0] WB_OP;
	reg [11:0] LA;
	reg [31:0] R_IOQ;
	
	always @(posedge CLK or negedge N_RST) begin
		if(~N_RST) begin
			WB_OP <= 0;
			LA <= 0;
		end else begin
			WB_OP <= LSU_OP[4:0];
			LA <= O[13:2];
			R_IOQ <= IOQ;
		end
	end
	
	assign JA2 = {DQ[20:16], DQ[31:26]};
	assign JREQ2 = WB_OP[3];
	
	assign IOE = O[13] ? LSU_OP[5] : 1'b0;
	assign IOD = D;
	assign IOA = O[5:2];
	
	assign DD = {D[7:0], D[15:8], D[23:16], D[31:24]};
	assign DA = O[12:2];
	assign DE = O[13] ? 1'b0 : LSU_OP[5];
	
	assign WD2 = LA[11] ? R_IOQ : {DQ[7:0], DQ[15:8], DQ[23:16], DQ[31:24]};
	assign WA2 = WB_OP[2:0];
	assign WE2 = WB_OP[4];
endmodule
