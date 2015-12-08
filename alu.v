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
	
	wire [8:0] S00, S10, S11, S20, S21, S30, S31;
	
	assign S00 = {1'b0, CSA_A[7:0]} + {1'b0, CSA_B[7:0]} + {8'b0, CSA_C};
	assign S10 = {1'b0, CSA_A[15:8]} + {1'b0, CSA_B[15:8]};
	assign S11 = {1'b0, CSA_A[15:8]} + {1'b0, CSA_B[15:8]} + 9'b1;
	assign S20 = {1'b0, CSA_A[23:16]} + {1'b0, CSA_B[23:16]};
	assign S21 = {1'b0, CSA_A[23:16]} + {1'b0, CSA_B[23:16]} + 9'b1;
	assign S30 = CSA_A[32:24] + CSA_B[32:24];
	assign S31 = CSA_A[32:24] + CSA_B[32:24] + 9'b1;
	
	wire [8:0] S0, S1, S2, S3;
	
	assign S0 = S00;
	assign S1 = S0[8] ? S11 : S10;
	assign S2 = S1[8] ? S21 : S20;
	assign S3 = S2[8] ? S31 : S30;
	
	assign CSA_O = {S3[8:0], S2[7:0], S1[7:0], S0[7:0]};
	
	wire [32:0] ADD, SUB, AND, OR, XOR, NEG, NOT, SLL, SRL, SRA;
	
	assign ADD = CSA_O;
	assign SUB = CSA_O;
	assign OR = {1'b0, A[31:0] | B[31:0]};
	assign AND = {1'b0, A[31:0] & B[31:0]};
	assign XOR = {1'b0, A[31:0] ^ B[31:0]};
	assign NOT = {1'b0, ~B[31:0]};
	assign NEG = CSA_O;
	
	wire [32:0] SLLT[0:31];
	
	assign SLLT[0] = {1'b0, RD2[31:0]};
	assign SLLT[1] = {RD2[31:0], 1'b0};
	assign SLLT[2] = {RD2[30:0], 2'b0};
	assign SLLT[3] = {RD2[29:0], 3'b0};
	assign SLLT[4] = {RD2[28:0], 4'b0};
	assign SLLT[5] = {RD2[27:0], 5'b0};
	assign SLLT[6] = {RD2[26:0], 6'b0};
	assign SLLT[7] = {RD2[25:0], 7'b0};
	assign SLLT[8] = {RD2[24:0], 8'b0};
	assign SLLT[9] = {RD2[23:0], 9'b0};
	assign SLLT[10] = {RD2[22:0], 10'b0};
	assign SLLT[11] = {RD2[21:0], 11'b0};
	assign SLLT[12] = {RD2[20:0], 12'b0};
	assign SLLT[13] = {RD2[19:0], 13'b0};
	assign SLLT[14] = {RD2[18:0], 14'b0};
	assign SLLT[15] = {RD2[17:0], 15'b0};
	assign SLLT[16] = {RD2[16:0], 16'b0};
	assign SLLT[17] = {RD2[15:0], 17'b0};
	assign SLLT[18] = {RD2[14:0], 18'b0};
	assign SLLT[19] = {RD2[13:0], 19'b0};
	assign SLLT[20] = {RD2[12:0], 20'b0};
	assign SLLT[21] = {RD2[11:0], 21'b0};
	assign SLLT[22] = {RD2[10:0], 22'b0};
	assign SLLT[23] = {RD2[9:0], 23'b0};
	assign SLLT[24] = {RD2[8:0], 24'b0};
	assign SLLT[25] = {RD2[7:0], 25'b0};
	assign SLLT[26] = {RD2[6:0], 26'b0};
	assign SLLT[27] = {RD2[5:0], 27'b0};
	assign SLLT[28] = {RD2[4:0], 28'b0};
	assign SLLT[29] = {RD2[3:0], 29'b0};
	assign SLLT[30] = {RD2[2:0], 30'b0};
	assign SLLT[31] = {RD2[1:0], 31'b0};
	
	assign SLL = SLLT[IM16[4:0]];
	
	wire [32:0] SRLT[0:31];
	
	assign SRLT[0] = {RD2[31:0], 1'b0};
	assign SRLT[1] = {1'b0, RD2[31:0]};
	assign SRLT[2] = {2'b0, RD2[31:1]};
	assign SRLT[3] = {3'b0, RD2[31:2]};
	assign SRLT[4] = {4'b0, RD2[31:3]};
	assign SRLT[5] = {5'b0, RD2[31:4]};
	assign SRLT[6] = {6'b0, RD2[31:5]};
	assign SRLT[7] = {7'b0, RD2[31:6]};
	assign SRLT[8] = {8'b0, RD2[31:7]};
	assign SRLT[9] = {9'b0, RD2[31:8]};
	assign SRLT[10] = {10'b0, RD2[31:9]};
	assign SRLT[11] = {11'b0, RD2[31:10]};
	assign SRLT[12] = {12'b0, RD2[31:11]};
	assign SRLT[13] = {13'b0, RD2[31:12]};
	assign SRLT[14] = {14'b0, RD2[31:13]};
	assign SRLT[15] = {15'b0, RD2[31:14]};
	assign SRLT[16] = {16'b0, RD2[31:15]};
	assign SRLT[17] = {17'b0, RD2[31:16]};
	assign SRLT[18] = {18'b0, RD2[31:17]};
	assign SRLT[19] = {19'b0, RD2[31:18]};
	assign SRLT[20] = {20'b0, RD2[31:19]};
	assign SRLT[21] = {21'b0, RD2[31:20]};
	assign SRLT[22] = {22'b0, RD2[31:21]};
	assign SRLT[23] = {23'b0, RD2[31:22]};
	assign SRLT[24] = {24'b0, RD2[31:23]};
	assign SRLT[25] = {25'b0, RD2[31:24]};
	assign SRLT[26] = {26'b0, RD2[31:25]};
	assign SRLT[27] = {27'b0, RD2[31:26]};
	assign SRLT[28] = {28'b0, RD2[31:27]};
	assign SRLT[29] = {29'b0, RD2[31:28]};
	assign SRLT[30] = {30'b0, RD2[31:29]};
	assign SRLT[31] = {31'b0, RD2[31:30]};
	
	assign SRL = SRLT[IM16[4:0]];
	
	wire [32:0] SRAT[0:31];
	
	assign SRAT[0] = {RD2[31:0], 1'b0};
	assign SRAT[1] = {RD2[31], RD2[31:0]};
	assign SRAT[2] = {{2{RD2[31]}}, RD2[31:1]};
	assign SRAT[3] = {{3{RD2[31]}}, RD2[31:2]};
	assign SRAT[4] = {{4{RD2[31]}}, RD2[31:3]};
	assign SRAT[5] = {{5{RD2[31]}}, RD2[31:4]};
	assign SRAT[6] = {{6{RD2[31]}}, RD2[31:5]};
	assign SRAT[7] = {{7{RD2[31]}}, RD2[31:6]};
	assign SRAT[8] = {{8{RD2[31]}}, RD2[31:7]};
	assign SRAT[9] = {{9{RD2[31]}}, RD2[31:8]};
	assign SRAT[10] = {{10{RD2[31]}}, RD2[31:9]};
	assign SRAT[11] = {{11{RD2[31]}}, RD2[31:10]};
	assign SRAT[12] = {{12{RD2[31]}}, RD2[31:11]};
	assign SRAT[13] = {{13{RD2[31]}}, RD2[31:12]};
	assign SRAT[14] = {{14{RD2[31]}}, RD2[31:13]};
	assign SRAT[15] = {{15{RD2[31]}}, RD2[31:14]};
	assign SRAT[16] = {{16{RD2[31]}}, RD2[31:15]};
	assign SRAT[17] = {{17{RD2[31]}}, RD2[31:16]};
	assign SRAT[18] = {{18{RD2[31]}}, RD2[31:17]};
	assign SRAT[19] = {{19{RD2[31]}}, RD2[31:18]};
	assign SRAT[20] = {{20{RD2[31]}}, RD2[31:19]};
	assign SRAT[21] = {{21{RD2[31]}}, RD2[31:20]};
	assign SRAT[22] = {{22{RD2[31]}}, RD2[31:21]};
	assign SRAT[23] = {{23{RD2[31]}}, RD2[31:22]};
	assign SRAT[24] = {{24{RD2[31]}}, RD2[31:23]};
	assign SRAT[25] = {{25{RD2[31]}}, RD2[31:24]};
	assign SRAT[26] = {{26{RD2[31]}}, RD2[31:25]};
	assign SRAT[27] = {{27{RD2[31]}}, RD2[31:26]};
	assign SRAT[28] = {{28{RD2[31]}}, RD2[31:27]};
	assign SRAT[29] = {{29{RD2[31]}}, RD2[31:28]};
	assign SRAT[30] = {{30{RD2[31]}}, RD2[31:29]};
	assign SRAT[31] = {{31{RD2[31]}}, RD2[31:30]};
	
	assign SRA = SRAT[IM16[4:0]];
	
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
