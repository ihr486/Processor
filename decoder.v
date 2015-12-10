module DECODER(CLK, N_RST, IR, PC, ALU_OP, ALUa_OP, RA1, RA2, WA1, IM16, IMA, HALT, STALL, VALID, BRAKE_IN, BRAKE_OUT);
	input CLK, N_RST;
	
	input [31:0] IR;
	input [10:0] PC;
	input VALID;
	input [10:0] BRAKE_IN;
	
	output [19:0] ALU_OP;
	input [19:0] ALUa_OP;
	output [2:0] RA1, RA2, WA1;
	output [15:0] IM16;
	output [10:0] IMA;
	
	output HALT;
	output STALL;
	output [10:0] BRAKE_OUT;
	
	reg [3:0] COND;
	reg [9:0] DEC_OP;
	reg [5:0] LSU_OP;
	reg [2:0] RA1, RA2, WA1;
	reg [15:0] IM16;
	reg [10:0] IMA;
	reg STOP;
	
	wire [31:0] INSTFLAG;
	
	wire PUSH, POP, PUSHPOP, RETURN, BRANCH;
	wire CALL, JUMP, IMM_LOAD, LOAD, STORE;
	wire REG_OP, LDST, MOV, NOP, IMM_OP, NN_OP;
	wire SHIFT, COND_BRANCH, HALT_OP;
	
	function [31:0] decode;
		input [31:0] INST;
		
		casex(INST[31:21])
			11'bxxxx1x1x_01x:	//zLD
				decode = 32'b00_0000_010000_0000_0000_0000_0000_0001;
			11'bxxxx1x0x_01x:	//zST
				decode = 32'b00_0000_010000_0000_0000_0000_0000_0010;
			11'bxxxx0xxx_01x:	//zBcc
				decode = 32'b00_0000_011010_0000_0000_0000_0000_0100;
				
			11'bxxxxxxxx_101:	//zLIL
				decode = 32'b00_1001_010100_0000_0000_0000_0000_1000;
			11'bxxx0xxxx_100:	//zRET
				decode = 32'b00_1110_000100_0000_0000_0000_0001_0000;
			11'b0xx10xxx_100:	//zPUSH
				decode = 32'b00_1000_000100_0000_0000_0000_0010_0000;
			11'b0xx11xxx_100:	//zPOP
				decode = 32'b00_1110_000100_0000_0000_0000_0100_0000;
			11'b10x1xxxx_100:	//zNOP
				decode = 32'b00_0000_000000_0000_0000_0000_1000_0000;
			11'b11x1xxxx_100:	//zHLT
				decode = 32'b00_0000_000000_0000_0000_0001_0000_0000;
				
			11'b10xx1xxx_11x:	//zMOV
				decode = 32'b00_0010_000100_0000_0000_0010_0000_0000;
			11'b0xxxxxxx_11x:	//zADD,zSUB,zAND,zOR,zXOR,zCMP
				decode = {3'b000, IR[29:27], 26'b100100_0000_0000_0100_0000_0000};
			11'b10x00xxx_11x:	//zADDI,zSUBI,zANDI,zORI,zXORI,zCMPI
				decode = {3'b000, IR[21:19], 26'b110100_0000_0000_1000_0000_0000};
			11'b11x10xxx_11x:	//zNEG,zNOT
				decode = {2'b00, IR[22:19], 26'b100100_0000_0001_0000_0000_0000};
			11'b11x00xxx_11x:	//zSLL,zSLA,zSRL,zSRA
				decode = {2'b00, IR[22:19], 26'b110100_0000_0010_0000_0000_0000};
			11'b10x10xxx_11x:	//zB
				decode = 32'b00_0000_011001_0000_0100_0000_0000_0000;
			11'b11xx1xxx_110:	//zJALR
				decode = 32'b00_1000_001101_0000_1000_0000_0000_0000;
			11'b11xx1xxx_111:	//zJR
				decode = 32'b00_0011_000001_0001_0000_0000_0000_0000;
			default:
				decode = 32'b00_0000_000000_0000_0000_0001_0000_0000;
		endcase
	endfunction
	
	assign INSTFLAG = decode(IR);
	
	assign PUSH = INSTFLAG[5];
	assign POP = INSTFLAG[6];
	assign PUSHPOP = PUSH | POP;
	assign RETURN = INSTFLAG[4];
	assign CALL = INSTFLAG[15];
	assign JUMP = INSTFLAG[16];
	assign IMM_LOAD = INSTFLAG[3];
	assign BRANCH = INSTFLAG[2] | INSTFLAG[14];
	assign LOAD = INSTFLAG[0];
	assign STORE = INSTFLAG[1];
	assign REG_OP = INSTFLAG[10];
	assign LDST = LOAD | STORE;
	assign MOV = INSTFLAG[9];
	assign NOP = INSTFLAG[7];
	assign IMM_OP = INSTFLAG[11];
	assign NN_OP = INSTFLAG[12];
	assign SHIFT = INSTFLAG[13];
	assign COND_BRANCH = INSTFLAG[2];
	assign HALT_OP = INSTFLAG[8];
	
	wire [2:0] R1, R2, R3;
	
	assign R1 = (PUSHPOP | RETURN | CALL) ? 3'd4 : IR[21:19];
	assign R2 = PUSHPOP ? IR[26:24] : IR[18:16];
	assign R3 = PUSHPOP ? IR[26:24] : IR[21:19];
	
	wire ER1, ER2;
	
	assign ER1 = PUSHPOP | RETURN | CALL | REG_OP | LDST | MOV;
	assign ER2 = ~(BRANCH | RETURN | NOP);
	
	wire MR1, MR2;
	
	assign MR1 = LOAD | PUSHPOP | RETURN | CALL;
	assign MR2 = (IR[23:22] == 2'b11 || PUSHPOP || IMM_LOAD) ? 1'b1 : 1'b0;
	
	wire HAZARD_RAL, HAZARD_RALa, HAZARD_FLAG, HAZARD_LSU;
	wire [7:0] HAZARD_REG;
	
	assign HAZARD_RAL = ALU_OP[4] & (((ALU_OP[2:0] == R1 && ER1) || (ALU_OP[2:0] == R2 && ER2)) ? 1'b1 : 1'b0);
	assign HAZARD_RALa = ALUa_OP[4] & (((ALUa_OP[2:0] == R1 && ER1) || (ALUa_OP[2:0] == R2 && ER2)) ? 1'b1 : 1'b0);
	
	assign ALU_OP = {COND, DEC_OP, LSU_OP};
	
	assign BRAKE_OUT[10] = BRAKE_IN[10] | (VALID & (CALL | PUSHPOP | RETURN | LDST));
	assign BRAKE_OUT[8] = BRAKE_IN[8] | (VALID & (REG_OP | IMM_OP | NN_OP | SHIFT));
	assign BRAKE_OUT[7] = BRAKE_IN[7] | (VALID & ((MR1 && R1 == 3'd7) | (MR2 && R2 == 3'd7)));
	assign BRAKE_OUT[6] = BRAKE_IN[6] | (VALID & ((MR1 && R1 == 3'd6) | (MR2 && R2 == 3'd6)));
	assign BRAKE_OUT[5] = BRAKE_IN[5] | (VALID & ((MR1 && R1 == 3'd5) | (MR2 && R2 == 3'd5)));
	assign BRAKE_OUT[4] = BRAKE_IN[4] | (VALID & ((MR1 && R1 == 3'd4) | (MR2 && R2 == 3'd4)));
	assign BRAKE_OUT[3] = BRAKE_IN[3] | (VALID & ((MR1 && R1 == 3'd3) | (MR2 && R2 == 3'd3)));
	assign BRAKE_OUT[2] = BRAKE_IN[2] | (VALID & ((MR1 && R1 == 3'd2) | (MR2 && R2 == 3'd2)));
	assign BRAKE_OUT[1] = BRAKE_IN[1] | (VALID & ((MR1 && R1 == 3'd1) | (MR2 && R2 == 3'd1)));
	assign BRAKE_OUT[0] = BRAKE_IN[0] | (VALID & ((MR1 && R1 == 3'd0) | (MR2 && R2 == 3'd0)));
	
	assign HAZARD_FLAG = BRAKE_IN[8] & COND_BRANCH;
	assign HAZARD_REG[7] = BRAKE_IN[7] & ((ER1 && R1 == 3'd7) | (ER2 && R2 == 3'd7));
	assign HAZARD_REG[6] = BRAKE_IN[6] & ((ER1 && R1 == 3'd6) | (ER2 && R2 == 3'd6));
	assign HAZARD_REG[5] = BRAKE_IN[5] & ((ER1 && R1 == 3'd5) | (ER2 && R2 == 3'd5));
	assign HAZARD_REG[4] = BRAKE_IN[4] & ((ER1 && R1 == 3'd4) | (ER2 && R2 == 3'd4));
	assign HAZARD_REG[3] = BRAKE_IN[3] & ((ER1 && R1 == 3'd3) | (ER2 && R2 == 3'd3));
	assign HAZARD_REG[2] = BRAKE_IN[2] & ((ER1 && R1 == 3'd2) | (ER2 && R2 == 3'd2));
	assign HAZARD_REG[1] = BRAKE_IN[1] & ((ER1 && R1 == 3'd1) | (ER2 && R2 == 3'd1));
	assign HAZARD_REG[0] = BRAKE_IN[0] & ((ER1 && R1 == 3'd0) | (ER2 && R2 == 3'd0));
	assign HAZARD_LSU = BRAKE_IN[10] & (CALL | PUSHPOP | RETURN | LDST);
	
	assign STALL = VALID & (HAZARD_RAL | HAZARD_RALa | HAZARD_FLAG | |{HAZARD_REG[7:0]} | HAZARD_LSU | BRAKE_IN[9]);
	assign HALT = (VALID & ((BRANCH | JUMP | RETURN | HALT_OP | CALL) & ~STALL)) | STOP;
	assign BRAKE_OUT[9] = BRAKE_IN[9] | (VALID & (HALT | STALL));
	
	always @(posedge CLK or negedge N_RST) begin
		if(~N_RST) begin
			COND <= 0;
			DEC_OP <= 0;
			IM16 <= 0;
			IMA <= 0;
			RA1 <= 0;
			RA2 <= 0;
			WA1 <= 0;
			LSU_OP <= 0;
			STOP <= 0;
		end else begin
			RA1 <= R1;
			RA2 <= R2;
			WA1 <= (PUSHPOP | RETURN | CALL) ? 3'd4 : IR[18:16];
			IM16 <= IMM_LOAD ? {IR[7:0], IR[15:8]} : {{8{IR[15]}}, IR[15:8]};
			IMA <= PC;
			COND <= IR[19:16];
		
			if(STOP | STALL | ~VALID) begin
				DEC_OP <= 0;
				LSU_OP <= 0;
			end else begin
				LSU_OP <= {CALL | PUSH | STORE, POP | LOAD, RETURN, R3};
				STOP <= HALT_OP;
				DEC_OP <= INSTFLAG[29:20];
			end
		end
	end
endmodule
