module RF(CLK, N_RST, RA1, RD1, RA2, RD2, RA3, RD3, RA4, RD4, WA1, WD1, WE1, WA2, WD2, WE2, WA3, WD3, WE3, WDF1, WEF1, WDF2, WEF2, FLAGS);
	input CLK, N_RST;
	
	input [2:0] RA1, RA2, RA3, RA4;
	output [31:0] RD1, RD2, RD3, RD4;
	input [2:0] WA1, WA2, WA3;
	input [31:0] WD1, WD2, WD3;
	input [4:0] WDF1, WDF2;
	input WE1, WE2, WE3, WEF1, WEF2;
	output [4:0] FLAGS;
	
	reg [4:0] FLAGS;
	reg [31:0] REG[0:7];
	
	always @(posedge CLK or negedge N_RST) begin
		if(~N_RST) begin
			REG[0] <= 32'b0;
			REG[1] <= 32'b0;
			REG[2] <= 32'b0;
			REG[3] <= 32'b0;
			REG[4] <= 32'b0;
			REG[5] <= 32'b0;
			REG[6] <= 32'b0;
			REG[7] <= 32'b0;
			FLAGS <= 5'b0;
		end else begin
			if(WE1) begin
				REG[WA1] <= WD1;
				if(WE2 && WA2 != WA1) begin
					REG[WA2] <= WD2;
					if(WE3 && WA3 != WA1 && WA3 != WA2) begin
						REG[WA3] <= WD3;
					end
				end else if(WE3 && WA3 != WA1) begin
					REG[WA3] <= WD3;
				end
			end else if(WE2) begin
				REG[WA2] <= WD2;
				if(WE3 && WA3 != WA2) begin
					REG[WA3] <= WD3;
				end
			end else if(WE3) begin
				REG[WA3] <= WD3;
			end
			if(WEF1) begin
				FLAGS <= WDF1;
			end else if(WEF2) begin
				FLAGS <= WDF2;
			end
		end
	end
	
	assign RD1 = REG[RA1];
	assign RD2 = REG[RA2];
	assign RD3 = REG[RA3];
	assign RD4 = REG[RA4];
endmodule
