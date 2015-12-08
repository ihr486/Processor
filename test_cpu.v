`timescale 10ps/1ps
module test_cpu;
	reg CLK, N_RST;
	
	wire [7:0] SEG_A, SEG_B, SEG_C, SEG_D, SEG_E, SEG_F, SEG_G, SEG_H;
	wire [8:0] SEG_SEL;
	wire BZ;
	
	reg [3:0] HEX_A, HEX_B;
	reg [7:0] DIP_A, DIP_B;
	reg [4:0] PSW_A, PSW_B, PSW_C, PSW_D;

	CPU cpu(CLK, N_RST, SEG_A, SEG_B, SEG_C, SEG_D, SEG_E, SEG_F, SEG_G, SEG_H, SEG_SEL, HEX_A, HEX_B, DIP_A, DIP_B, PSW_A, PSW_B, PSW_C, PSW_D, BZ);

	integer i;
	
	initial begin
		N_RST = 1'b1;
		#5 CLK = 1'b0;
		#5 N_RST = 1'b0;
		#5 N_RST = 1'b1;
		
		for(i = 0; i < 500000; i = i + 1) begin
			#5 CLK = ~CLK;
		end
	end
endmodule
