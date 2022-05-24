module random (input Clk,
				input frame_clk,
				input Reset,
				output [2:0] randnum_b
	);
	
	logic frame_clk_delayed, frame_clk_rising_edge;
	always_ff @ (posedge Clk)
	begin
		frame_clk_delayed <= frame_clk;
		frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
	
		if (Reset)
			randnum_b <= 3'b111;
		else if (randnum_b == 3'b000)
			randnum_b	<= 3'b111;
		else if (frame_clk_rising_edge)
		begin
			randnum_b[2] <= randnum_b[1];
			randnum_b[1] <= randnum_b[0]^randnum_b[2];
			randnum_b[0] <= randnum_b[2];
		end
	end	
	
endmodule
