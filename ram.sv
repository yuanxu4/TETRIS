/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  frameROM
(
		input int  address,
		input Clk,

		output logic [23:0] color_data
);

// mem has width of 3 bits and a total of 400 addresses
logic [23:0] mem [0:399];

initial
begin
	 $readmemh("tetris_I.txt", mem);
end


always_ff @ (posedge Clk) begin
	color_data<= mem[address];
end

endmodule
