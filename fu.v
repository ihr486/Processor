module FU(CLK, N_RST, IA, ID, IR1, PC1, VALID1, STALL1, IR2, PC2, VALID2, STALL2, HALT, JA, JREQ);
	input CLK, N_RST;
	
	output [9:0] IA;
	input [63:0] ID;
	
	output [31:0] IR1, IR2;
	output [10:0] PC1, PC2;
	output VALID1, VALID2;
	
	input STALL1, STALL2, HALT, JREQ;
	input [10:0] JA;
	
	reg [9:0] PC, PC0;
	reg [31:0] IC;
	reg VALID, VALID1, VALID2, STARTUP;
	reg FS;
	
	wire [31:0] ID1, ID2;
	
	assign ID1 = ID[31:0];
	assign ID2 = ID[63:32];
	
	always @(posedge CLK or negedge N_RST) begin
		if(~N_RST) begin
			PC <= 10'b0;
			PC0 <= 10'b0;
			VALID <= 1'b1;
			VALID1 <= 1'b0;
			VALID2 <= 1'b0;
			STARTUP <= 1'b1;
			FS <= 1'b0;
			IC <= 32'h90909090;
		end else begin
			if(STARTUP) begin
				STARTUP <= 1'b0;
				VALID1 <= 1'b1;
				VALID2 <= 1'b1;
				PC <= PC + 10'b1;
			end else if(JREQ) begin
				FS <= 1'b0;
				PC <= JA[10:1] + 10'b1;
				VALID <= 1'b1;
				VALID1 <= ~JA[0];
				VALID2 <= 1'b1;
			end else if(FS == 1'b0) begin
				if(STALL1) begin
				end else if(STALL2) begin
					FS <= 1'b1;
					PC <= PC + 10'b1;
					PC0 <= PC;
					IC <= ID2;
				end else begin
					PC <= PC + 10'b1;
					PC0 <= PC;
					IC <= ID2;
				end
				VALID <= ~HALT & VALID;
				VALID1 <= ~HALT & VALID; 
				VALID2 <= ~HALT & VALID;
			end else begin
				if(STALL1) begin
				end else if(STALL2) begin
					FS <= 1'b0;
				end else begin
					PC <= PC + 10'b1;
					PC0 <= PC;
					IC <= ID2;
				end
				VALID <= ~HALT & VALID;
				VALID1 <= ~HALT & VALID;
				VALID2 <= ~HALT & VALID;
			end
		end
	end
	
	assign IA = JREQ ? JA[10:1] : ((STALL1 | (STALL2 & FS)) ? PC0 : PC);
	assign PC1 = FS ? {PC - 10'b1, 1'b0} : {PC - 10'b1, 1'b1};
	assign PC2 = FS ? {PC - 10'b1, 1'b1} : {PC, 1'b0};
	assign IR1 = FS ? IC : ID1;
	assign IR2 = FS ? ID1 : ID2;
endmodule
