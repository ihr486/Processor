module CPU(CLK, N_RST, SEG_A, SEG_B, SEG_C, SEG_D, SEG_E, SEG_F, SEG_G, SEG_H, SEG_SEL, HEX_A, HEX_B, DIP_A, DIP_B, PSW_A, PSW_B, PSW_C, PSW_D, BZ);
	input CLK, N_RST;
	
	output [7:0] SEG_A, SEG_B, SEG_C, SEG_D, SEG_E, SEG_F, SEG_G, SEG_H;
	output [8:0] SEG_SEL;
	input [3:0] HEX_A, HEX_B;
	input [7:0] DIP_A, DIP_B;
	input [4:0] PSW_A, PSW_B, PSW_C, PSW_D;
	output BZ;
	
	wire [3:0] IOA;
	wire [31:0] IOD, IOQ;
	wire IOE;
	
	reg [31:0] OUT[0:15];
	wire [31:0] IN[0:15];
	
	always @(posedge CLK or negedge N_RST) begin
		if(~N_RST) begin
			OUT[0] <= 32'b0;
			OUT[1] <= 32'b0;
			OUT[2] <= 32'b0;
			OUT[3] <= 32'b0;
			OUT[4] <= 32'b0;
			OUT[5] <= 32'b0;
			OUT[6] <= 32'b0;
			OUT[7] <= 32'b0;
			OUT[8] <= 32'b0;
			OUT[9] <= 32'b0;
			OUT[10] <= 32'b0;
			OUT[11] <= 32'b0;
			OUT[12] <= 32'b0;
			OUT[13] <= 32'b0;
			OUT[14] <= 32'b0;
			OUT[15] <= 32'b0;
		end else begin
			if(IOE) begin
				OUT[IOA] <= IOD;
			end
		end
	end
	
	assign IOQ = IN[IOA];
	
	assign SEG_A = OUT[0][7:0];
	assign SEG_B = OUT[1][7:0];
	assign SEG_C = OUT[2][7:0];
	assign SEG_D = OUT[3][7:0];
	assign SEG_E = OUT[4][7:0];
	assign SEG_F = OUT[5][7:0];
	assign SEG_G = OUT[6][7:0];
	assign SEG_H = OUT[7][7:0];
	assign SEG_SEL = OUT[8][8:0];
	assign BZ = OUT[9][0];
	
	assign IN[0] = {28'b0, HEX_A[3:0]};
	assign IN[1] = {28'b0, HEX_B[3:0]};
	assign IN[2] = {24'b0, DIP_A[7:0]};
	assign IN[3] = {24'b0, DIP_B[7:0]};
	assign IN[4] = {27'b0, PSW_A[4:0]};
	assign IN[5] = {27'b0, PSW_B[4:0]};
	assign IN[6] = {27'b0, PSW_C[4:0]};
	assign IN[7] = {27'b0, PSW_D[4:0]};
	assign IN[8] = 32'b0;
	assign IN[9] = 32'b0;
	assign IN[10] = 32'b0;
	assign IN[11] = 32'b0;
	assign IN[12] = 32'b0;
	assign IN[13] = 32'b0;
	assign IN[14] = 32'b0;
	assign IN[15] = 32'b0;
	
	wire [9:0] IA;
	wire [10:0] DA;
	wire [31:0] DD, DQ;
	wire [63:0] ID;
	wire DE;
	
	memory ram(IA, DA, CLK, 64'b0, DD, 1'b0, DE, ID, DQ);
	
	wire [2:0] RA1, RA2, RA3, RA4;
	wire [31:0] RD1, RD2, RD3, RD4;
	wire [2:0] WA1, WA2, WA3;
	wire [31:0] WD1, WD2, WD3;
	wire WE1, WE2, WE3;
	wire WEF1, WEF2;
	wire [4:0] WDF1, WDF2;
	wire [4:0] FLAGS;
	
	RF rf(CLK, N_RST, RA1, RD1, RA2, RD2, RA3, RD3, RA4, RD4, WA1, WD1, WE1, WA2, WD2, WE2, WA3, WD3, WE3, WDF1, WEF1, WDF2, WEF2, FLAGS);
	
	wire [31:0] IR1, IR2;
	wire [10:0] PC1, PC2;
	wire VALID1, VALID2;
	wire STALL1, STALL2;
	wire [10:0] JA;
	wire JREQ;
	wire HALT;
	
	FU fu(CLK, N_RST, IA, ID, IR1, PC1, VALID1, STALL1, IR2, PC2, VALID2, STALL2, HALT, JA, JREQ);
	
	wire [19:0] ALU1_OP, ALU2_OP;
	wire [15:0] ALU1_IM16, ALU2_IM16;
	wire [10:0] ALU1_IMA, ALU2_IMA;
	wire HALT1, HALT2;
	wire [10:0] BRAKE1, BRAKE2;
	
	DECODER dec1(CLK, N_RST, IR1, PC1, ALU1_OP, ALU2_OP, RA1, RA2, WA2, ALU1_IM16, ALU1_IMA, HALT1, STALL1, VALID1, 11'b0, BRAKE1);
	
	DECODER dec2(CLK, N_RST, IR2, PC2, ALU2_OP, ALU1_OP, RA3, RA4, WA1, ALU2_IM16, ALU2_IMA, HALT2, STALL2, VALID2, BRAKE1, BRAKE2);
	
	wire [5:0] LSU_OP1, LSU_OP2;
	wire [10:0] JA1, JA2;
	wire JREQ1, JREQ2;
	wire [31:0] D1, D2, O1, O2;
	
	ALU alu1(CLK, N_RST, ALU1_OP, LSU_OP1, ALU1_IM16, ALU1_IMA, RD1, RD2, WD2, WE2, JA1, JREQ1, D1, O1, WEF2, WDF2, FLAGS);
	
	ALU alu2(CLK, N_RST, ALU2_OP, LSU_OP2, ALU2_IM16, ALU2_IMA, RD3, RD4, WD1, WE1, JA2, JREQ2, D2, O2, WEF1, WDF1, FLAGS);
	
	wire [10:0] JA3;
	wire JREQ3;
	wire [5:0] LSU_OP;
	wire [31:0] D, O;
	
	LSU lsu(CLK, N_RST, LSU_OP, D, O, DA, DD, DE, DQ, WA3, WD3, WE3, JA3, JREQ3, IOA, IOD, IOQ, IOE);

	assign LSU_OP = |{LSU_OP2[5:3]} ? LSU_OP2 : LSU_OP1;
	assign D = |{LSU_OP2[5:3]} ? D2 : D1;
	assign O = |{LSU_OP2[5:3]} ? O2 : O1;
	assign HALT = HALT1 | HALT2;
	assign JREQ = JREQ1 | JREQ2 | JREQ3;
	assign JA = JREQ1 ? JA1 : (JREQ2 ? JA2 : JA3);
endmodule
