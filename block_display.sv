module  block_state   ( input          		Clk,                  // 50 MHz clock
															Reset,              // Active-high reset signal	
								input                touched,
															gg, 
															go_next,
								input  [7:0]			keycode,
								output 					new_block,
															go_down,
															fast_down,
															go_right,
															go_left,
															switch,
															clear,
															clearall
								);
			
	enum logic [3:0] {  	Halted,
								Halted_2,
								newblock,
								control,
								control_switch,
								control_switch2,
								fast_control,
								control_right,
								//control_right1_2,
								control_right2,
								control_left,
								//control_left1_2,
								control_left2,
								touch,
								over,
								over2
								}   State, Next_state;
    
	always_ff @ (posedge Clk)
	begin
		if (Reset) 
			State <= Halted;
		else
			State <= Next_state;
	end
	
	always_comb
	begin 
		Next_state = State;
		unique case (State)
			Halted : 
				if (keycode == 8'h28) 
					Next_state = Halted_2;
				else
					Next_state = Halted;
			Halted_2 : 
				if (keycode == 8'd00)
					Next_state = newblock;
			newblock :
				Next_state = control;
			control :
				if(touched)
					Next_state = touch;
				else begin
					if(keycode == 8'h04)
						Next_state = control_left;
					else if(keycode == 8'h07)
						Next_state = control_right;
					else if(keycode == 8'h16)
						Next_state = fast_control;
					else if(keycode == 8'h1a)
						Next_state = control_switch;
					else
						Next_state = control;
				end
			control_switch :
					Next_state = control_switch2;
			control_switch2 :
				if(touched)
					Next_state = touch;
				else if (keycode == 8'h00)
					Next_state = control;
				else
					Next_state = control_switch2;
				
			fast_control :
				if(touched)
					Next_state = touch;
				else if(keycode == 8'h00)
					Next_state = control;
				else 
					Next_state = fast_control;
			control_right :
					Next_state = control_right2;
			control_right2 :
				if(touched)
					Next_state = touch;
				else if (keycode == 8'h00)
					Next_state = control;
				else
					Next_state = control_right2;
			control_left :
					Next_state = control_left2;

			control_left2 :
			begin
				if(touched)
					Next_state = touch;
				else if (keycode == 8'h00)
					Next_state = control;
				else
					Next_state = control_left2;
			end
			touch :
				if(gg)
					Next_state = over;
				else if(go_next)
					Next_state = newblock;
				else
					Next_state = touch;
			over :
				if (keycode == 8'h28) 
					Next_state = over2;
				else
					Next_state = over;
			over2 :
				if (keycode == 8'd00)
					Next_state = Halted;


			default : Next_state = Halted;

		endcase
		
		new_block = 1'b0;
		go_down = 1'b0;
		go_right=1'b0;
		go_left = 1'b0;
		switch = 1'b0;
		clear = 1'b0;
		clearall = 1'b0;
 		fast_down = 1'b0;
		unique case (State)
			Halted : ;
				
			Halted_2 : ;
				
			newblock :
				new_block = 1'b1;
				
			control :
			begin
				new_block = 1'b0;
				go_down = 1'b1;
			end	
			control_switch :
			begin
				go_down = 1'b0;
				switch = 1'b1;
			end
			control_switch2 :
			begin
				go_down = 1'b1;
				switch = 1'b0;
			end
			fast_control :
			begin
				go_down = 1'b1;
				fast_down = 1'b1;
			end
			control_right :
			begin
				go_down = 1'b0;
				go_right = 1'b1;
			end
			control_right2 :
			begin
				go_right = 1'b0;
				go_down = 1'b1;
			end
			control_left :
			begin
				go_left = 1'b1;
				go_down = 1'b0;
			end
			control_left2 :
			begin
				go_left = 1'b0;
				go_down = 1'b1;
			end
			touch :
			begin	
				go_down = 1'b0;
				clear = 1'b1;
			end
			over : ;
			over2 :
				clearall = 1'b1;
			

			default : ;
		endcase
	end 
    
endmodule

module block_display (	input          		Clk,                // 50 MHz clock
								
															Reset,
								input 					new_block,
															go_down,
															fast_down,
															go_right,
															go_left,
															switch,
															clear, 
															clearall,
								input [2:0]				randnum_b,
								output					gg,
															go_next,
															touched,
															record,
								output [3:0][3:0]		block_keep,
								output [19:0][9:0]   block_map,
								output [10:0]        score
);

reg [25:0] count_reg = 0;
reg clk1 = 0;
logic [25:0] count;
logic [2:0] block1,block1_h; 
logic [10:0] score_h;
logic [16:0] score_count;

always_comb 
begin
case (block1)
			3'b000 :	
				block_keep = { 4'b0000,
									4'b0110,
									4'b0110,
									4'b0000};
			3'b001 :
				block_keep = { 4'b0100,
									4'b0100,
									4'b0110,
									4'b0000};
			3'b010 :
				block_keep = { 4'b0000,
									4'b0110,
									4'b0010,
									4'b0010};
			3'b011 :
				block_keep = { 4'b0010,
									4'b0110,
									4'b0100,
									4'b0000};
			3'b100 :
				block_keep = { 4'b0100,
									4'b0110,
									4'b0010,
									4'b0000};
			3'b101 :
				block_keep = { 4'b0100,
									4'b0110,
									4'b0100,
									4'b0000};
			3'b110 :
				block_keep = { 4'b0100,
									4'b0100,
									4'b0100,
									4'b0100};
			default : 
				block_keep = { 4'b0000,
									4'b0110,
									4'b0110,
									4'b0000};
		endcase
end

always_comb 
begin
if(fast_down)
	count = 2999999;
else if(score[5])
	count = 4999999;
else if(score[4])
	count = 9999999;
else if(score[3])
	count = 19999999;
else if(score[2])
	count = 39999999;
else
	count = 49999999;
end

enum logic [2:0] { S_block,
						 L_block,
						 TL_block,
						 F_block,
						 TF_block,
						 T_block,
						 I_block
								}   block_type,block_type_in;

always @(posedge Clk or posedge Reset) begin
    if (Reset) begin
        count_reg <= 0;
        clk1 <= 0;
    end else begin
        clk1 <= 0;
        if (count_reg < count) begin
            count_reg <= count_reg + 1;
        end else begin
            count_reg <= 0;
            clk1 <= 1;
		  end
        end
end

logic clk1_delayed, clk1_rising_edge;
    always_ff @ (posedge Clk) begin
        clk1_delayed <= clk1;
        clk1_rising_edge <= (clk1 == 1'b1) && (clk1_delayed == 1'b0);
    end

logic [19:0][9:0] current_block;
logic [19:0][9:0] current_base;
logic [19:0][9:0] current_block_in;
logic [19:0][9:0] current_base_in;
int blockX,blockY,blockX_in,blockY_in;

always_ff @ (posedge Clk)
    begin
        if (Reset)
		  begin
				current_block <= {200'b0};
				current_base <= {200'b0};
				blockX <= 0;
				blockY <= 0;
				block1 <= 2'b001;
				block_type <= S_block;
				score <= 11'b0;
				score_count <= 0;
				
		  end
        else
		  begin
				current_base <= current_base_in;
				current_block <= current_block_in;
				blockX <= blockX_in;
				blockY <= blockY_in;
				block1 <= block1_h;
				score <= score_h;
				block_type <= block_type_in;
				
		  end
    end


	 
always_comb
	begin
	current_base_in = current_base;
	current_block_in = current_block;
	blockX_in = blockX;
	blockY_in = blockY;
	block1_h = block1;
	score_h = score;
	block_type_in = block_type;
	touched = 1'b0;
	gg = 1'b0;
	go_next = 1'b0;
	record = 0;
	score_count = 0;
	
		if(new_block)
		begin  
			case (block1)
			3'b000 :	
			begin
				current_block_in = {180'b0,10'b0000110000,
													10'b0000110000};
				block_type_in = S_block;
			end
			3'b001 :
			begin
				current_block_in = {170'b0,10'b0000100000,
													10'b0000100000,
													10'b0000110000};
				block_type_in = L_block;
			end
			3'b010 :
			begin
				current_block_in = {170'b0,10'b0001100000,
													10'b0000100000,
													10'b0000100000};
				block_type_in = TL_block;
			end
			3'b011 :
			begin
				current_block_in = {170'b0,10'b0000100000,
													10'b0001100000,
													10'b0001000000};
				block_type_in = F_block;
			end
			3'b100 :
			begin
				current_block_in = {170'b0,10'b0000100000,
													10'b0000110000,
													10'b0000010000};
				block_type_in = TF_block;
			end
			3'b101 :
			begin
				current_block_in = {170'b0,10'b0000100000,
													10'b0000110000,
													10'b0000100000};
				block_type_in = T_block;
			end
			3'b110 :
			begin
				current_block_in = {160'b0,10'b0000100000,
													10'b0000100000,
													10'b0000100000,
													10'b0000100000};
				block_type_in = I_block;
			end
			default : 
			begin
				current_block_in = {180'b0,10'b0000110000,
													10'b0000110000};
				block_type_in = S_block;
			end
		endcase
		begin
			blockX_in = 5;
			blockY_in = 1;
			block1_h = randnum_b;
		end
		end
		else if (go_down)
		begin
			if(clk1_rising_edge)
			begin
				current_block_in = current_block<<10;
				blockY_in = blockY + 1;
			end
			if((current_block_in & current_base)|(current_block[19] & {10'b1111111111}))
			begin
				touched = 1'b1;
				current_block_in = {200'b0};
				current_base_in = current_base | current_block;
			end
		end
		else if (switch)
		begin
		
		if((block_type == L_block) | (block_type == TL_block) | (block_type == F_block) | (block_type == TF_block) | (block_type == T_block) )
		begin
			current_block_in[(blockY + 1)][blockX] = current_block[blockY ][ blockX + 1];
			current_block_in[blockY][blockX - 1  ] = current_block[(blockY + 1)][blockX];
			current_block_in[(blockY - 1)][blockX] = current_block[blockY ][ blockX - 1];
			current_block_in[blockY][blockX + 1  ] = current_block[(blockY - 1)][blockX];
			
			current_block_in[(blockY + 1)][ blockX + 1] = current_block[(blockY - 1)][blockX + 1];
			current_block_in[(blockY - 1)][ blockX + 1] = current_block[(blockY - 1)][blockX - 1];
			current_block_in[(blockY - 1)][ blockX - 1] = current_block[(blockY + 1)][blockX - 1];
			current_block_in[(blockY + 1)][ blockX - 1] = current_block[(blockY + 1)][blockX + 1];
			if((current_block_in & current_base)|(blockX == 0)|(blockX == 9)|(blockY == 19))
			begin
				current_block_in = current_block;
			end
		end
		else if (block_type == I_block)
		begin
			current_block_in[blockY-1][blockX] = current_block[blockY][blockX+1];
			current_block_in[blockY+1][blockX] = current_block[blockY][blockX-1];
			current_block_in[blockY+2][blockX] = current_block[blockY][blockX-2];
			current_block_in[blockY][blockX+1] = current_block[blockY-1][blockX];
			current_block_in[blockY][blockX-1] = current_block[blockY+1][blockX];
			current_block_in[blockY][blockX-2] = current_block[blockY+2][blockX];
		
		if((current_block_in & current_base)|(blockX == 1)|(blockX == 9)|(blockY == 19)|(blockX == 0))
			begin
				current_block_in = current_block;
			end
		end
		end
		else if (go_right)
		begin
				current_block_in = current_block<<1;
				blockX_in = blockX + 1;
			if((current_block_in & current_base)|(current_block & {20{10'b1000000000}}))
			begin
				current_block_in = current_block;
				blockX_in = blockX;
			end
		end
		else if (go_left)
		begin
				current_block_in = current_block>>1;
				blockX_in = blockX - 1;
			if((current_block_in  & current_base)|(current_block & {20{10'b0000000001}}))
			begin
				current_block_in = current_block;
				blockX_in = blockX;
			end
		end
		else if(clear)
			begin
				if((current_base[3] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[3:0] = current_base_in[3:0] <<10;
					score_count[0] = 1;
				end
				if((current_base[4] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[4:0] = current_base_in[4:0] <<10;
					score_count[1] = 1;
				end
				if((current_base[5] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[5:0] = current_base_in[5:0] <<10;
					score_count[2] = 1;
				end
				if((current_base[6] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[6:0] = current_base_in[6:0] <<10;
					score_count[3] = 1;
				end
				if((current_base[7] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[7:0] = current_base_in[7:0] <<10;
					score_count[4] = 1;
				end
				if((current_base[8] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[8:0] = current_base_in[8:0] <<10;
					score_count[5] = 1;
				end
				if((current_base[9] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[9:0] = current_base_in[9:0] <<10;
					score_count[6] = 1;
				end
				if((current_base[10] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[10:0] = current_base_in[10:0] <<10;
					score_count[7] = 1;
				end
				if((current_base[11] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[11:0] = current_base_in[11:0] <<10;
					score_count[8] = 1;
				end
				if((current_base[12] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[12:0] = current_base_in[12:0] <<10;
					score_count[9] = 1;
				end
				if((current_base[13] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[13:0] = current_base_in[13:0] <<10;
					score_count[10] = 1;
				end
				if((current_base[14] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[14:0] = current_base_in[14:0] <<10;
					score_count[11] = 1;
				end
				if((current_base[15] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[15:0] = current_base_in[15:0] <<10;
					score_count[12] = 1;
				end
				if((current_base[16] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[16:0] = current_base_in[16:0] <<10;
					score_count[13] = 1;
				end
				if((current_base[17] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[17:0] = current_base_in[17:0] <<10;
					score_count[14] = 1;
				end
				if((current_base[18] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[18:0] = current_base_in[18:0] <<10;
					score_count[15] = 1;
				end
				if((current_base[19] & {10'b1111111111} )== {10'b1111111111})
				begin
					current_base_in[19:0] = current_base_in[19:0] <<10;
					score_count[16] = 1;
				end
				score_h = score + score_count[0] + score_count[1] + score_count[2]+ score_count[3]+ score_count[4]+ score_count[5]+ score_count[6]
				+ score_count[7]+ score_count[8]+ score_count[9]+ score_count[10]+ score_count[11]+ score_count[12]+ score_count[13]+ score_count[14]
				+ score_count[15]+ score_count[16];
					
				if(current_base_in & {160'b0,10'b1111111111,30'b0})
					gg = 1'b1;
				else
					go_next = 1'b1;
			end
		else if(clearall)
		begin
			current_base_in = 0;
			record = 1;
			score_h = 0;
		end
			
			
	end

	
always_comb
begin
	block_map = current_base | current_block;
end

	 
endmodule

module rank(input              Clk,         // 50 MHz clock
                               Reset,
				input logic [10:0] score,
				input logic record,
				output logic [10:0] score1,
										  score2,
										  score3);
	logic [10:0] score1_h,score2_h,score3_h;
	always_ff @ (posedge Clk)
    begin
        if (Reset)
		  begin
				score1 <= 0;
				score2 <= 0;
				score3 <= 0;
		  end
        else
		  begin
				score1 <= score1_h;
				score2 <= score2_h;
				score3 <= score3_h;
		  end
    end
	always_comb
	begin
		score1_h = score1;
		score2_h = score2;
		score3_h = score3;
		if(record)
		begin
			if(score > score1)
			begin
			score1_h = score;
			score2_h = score1;
			score3_h = score2;
			end
			else
			begin
				if(score > score2)
				begin
				score2_h = score;
				score3_h = score2;
				end
				else
				begin
					if(score > score3)
						score3_h = score;
				end
			end
		end
	end
				
endmodule

