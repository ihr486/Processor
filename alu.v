module ALU(CLK, N_RST, ALU_OP, LSU_OP, IM16, IMA, RD1, RD2, WD1, WE1, JA1, JREQ1, D, O, WEF, WDF, FLAGS);
	input CLK, N_RST;
	
	input [19:0] ALU_OP;
	output [5:0] LSU_OP;
	
	input [15:0] IM16;
	input [10:0] IMA;
	input [31:0] RD1, RD2;
	output [31:0] WD1;
	
	output WE1, WEF;
	output [10:0] JA1;
	output JREQ1;
	output [4:0] WDF;
	input [4:0] FLAGS;
	
	output [31:0] D, O;
	
	wire [31:0] A, B;
	
	assign A = ALU_OP[10] ? {{16{IM16[15]}}, IM16[15:0]} : RD1;
	assign B = ALU_OP[9] ? {19'b0, IMA[10:0], 2'b0} : RD2;
	
	wire [32:0] CSA_A, CSA_B;
	wire CSA_C;
	wire [32:0] CSA_O;
	
	assign CSA_A = (ALU_OP[15] & ALU_OP[12]) ? 33'b0 : (ALU_OP[12] ? {1'b1, ~A} : {1'b0, A[31:0]});
	assign CSA_B = ALU_OP[15] ? (ALU_OP[12] ? {1'b1, ~B} : (ALU_OP[14] ? 33'd4 : ~33'd4)) : {1'b0, B};
	assign CSA_C = ALU_OP[15] ^ ALU_OP[14];
	
	assign CSA_O = CSA_A + CSA_B + CSA_C;
	
	wire [32:0] ADD, SUB, AND, OR, XOR, NEG, NOT, SLL, SRL, SRA;
	
	assign ADD = CSA_O;
	assign SUB = CSA_O;
	assign OR = {1'b0, A[31:0] | B[31:0]};
	assign AND = {1'b0, A[31:0] & B[31:0]};
	assign XOR = {1'b0, A[31:0] ^ B[31:0]};
	assign NOT = {1'b0, ~B[31:0]};
	assign NEG = CSA_O;
	
	assign SLL = {1'b0, RD2[31:0]} << IM16[4:0];
	assign SRL = {RD2[31:0], 1'b0} >> IM16[4:0];
	assign SRA = {RD2[31:0], 1'b0} >>> IM16[4:0];
	
	wire [31:0] RESULT[0:15];
	
	assign RESULT[0] = ADD[31:0];
	assign RESULT[1] = OR[31:0];
	assign RESULT[2] = A;
	assign RESULT[3] = B;
	assign RESULT[4] = AND[31:0];
	assign RESULT[5] = SUB[31:0];
	assign RESULT[6] = XOR[31:0];
	assign RESULT[7] = B;
	assign RESULT[8] = CSA_O[31:0];
	assign RESULT[9] = {B[31:16], IM16[15:0]};
	assign RESULT[10] = NOT[31:0];
	assign RESULT[11] = NEG[31:0];
	assign RESULT[12] = SLL[31:0];
	assign RESULT[13] = SRL[32:1];
	assign RESULT[14] = CSA_O[31:0];
	assign RESULT[15] = SRA[32:1];
	
	wire SF, ZF, PF, OF, CF;
	
	assign SF = FLAGS[4];
	assign ZF = FLAGS[3];
	assign PF = FLAGS[2];
	assign OF = FLAGS[1];
	assign CF = FLAGS[0];
	
	wire [4:0] F[0:15];
	
	assign F[0] = {ADD[31], ~|{ADD[31:0]}, ~^{ADD[7:0]}, (A[31] ^ ADD[31]) & ~(A[31] ^ B[31]), ADD[32]};
	assign F[1] = {OR[31], ~|{OR[31:0]}, ~^{OR[7:0]}, 1'b0, 1'b0};
	assign F[2] = FLAGS;
	assign F[3] = FLAGS;
	assign F[4] = {AND[31], ~|{AND[31:0]}, ~^{AND[7:0]}, 1'b0, 1'b0};
	assign F[5] = {SUB[31], ~|{SUB[31:0]}, ~^{SUB[7:0]}, (B[31] ^ SUB[31]) & (A[31] ^ B[31]), SUB[32]};
	assign F[6] = {XOR[31], ~|{XOR[31:0]}, ~^{XOR[7:0]}, 1'b0, 1'b0};
	assign F[7] = {SUB[31], ~|{SUB[31:0]}, ~^{SUB[7:0]}, (B[31] ^ SUB[31]) & (A[31] ^ B[31]), SUB[32]};
	assign F[8] = FLAGS;
	assign F[9] = FLAGS;
	assign F[10] = FLAGS;
	assign F[11] = {NEG[31], ~|{NEG[31:0]}, ~^{NEG[7:0]}, 1'b0, |{B[31:0]}};
	assign F[12] = {SLL[31], ~|{SLL[31:0]}, ~^{SLL[7:0]}, (A[4:0] == 0) ? OF : (SLL[31] ^ SLL[32]), SLL[32]};
	assign F[13] = {SRL[32], ~|{SRL[32:1]}, ~^{SRL[8:1]}, (A[4:0] == 0) ? OF : B[31], SRL[0]};
	assign F[14] = FLAGS;
	assign F[15] = {SRA[32], ~|{SRA[32:1]}, ~^{SRL[8:1]}, (A[4:0] == 0) ? OF : 1'b0, SRA[0]};
	
	wire CB[0:7];
	
	assign CB[0] = OF;
	assign CB[1] = CF;
	assign CB[2] = ZF;
	assign CB[3] = CF | ZF;
	assign CB[4] = SF;
	assign CB[5] = PF;
	assign CB[6] = SF ^ OF;
	assign CB[7] = (SF ^ OF) | ZF;
	
	wire [10:0] BA;
	
	assign BA = ALU_OP[8] ? RD2[12:2] : RESULT[ALU_OP[15:12]][12:2];
	
	assign WEF = ALU_OP[11];
	assign WDF = F[ALU_OP[15:12]];
	
	assign JREQ1 = ALU_OP[6] | ALU_OP[7];
	assign JA1 = (ALU_OP[6] | (CB[ALU_OP[19:17]] ^ ALU_OP[16])) ? BA : IMA;
	
	assign WD1 = RESULT[ALU_OP[15:12]];
	assign WE1 = ALU_OP[8];
	assign D = ALU_OP[15] ? B : RD1;
	assign O = (ALU_OP[15:12] == 4'd14) ? A : RESULT[ALU_OP[15:12]];
	assign LSU_OP = ALU_OP[5:0];
endmodule
