//-------------------------------------------------------------------------
//    Color_Mapper.sv                                                    --
//    Stephen Kempf                                                      --
//    3-1-06                                                             --
//                                                                       --
//    Modified by David Kesler  07-16-2008                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  10-06-2017                               --
//                                                                       --
//    Fall 2017 Distribution                                             --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    University of Illinois ECE Department                              --
//-------------------------------------------------------------------------

// color_mapper: Decide which color to be output to VGA for each pixel.
module  color_mapper ( input			[23:0] color_data,
							  input			[19:0][9:0] block_map,
							  input			[3:0][3:0]  block_keep,
                       input        [9:0] DrawX, DrawY,       // Current pixel coordinates
							  input			[10:0] score,score1,score2,score3,
                       output logic [7:0] VGA_R, VGA_G, VGA_B // VGA RGB output
                     );
    
    logic [7:0] Red, Green, Blue;
	 logic [9:0] addr;
	 logic [7:0] data;
	 
	 alphabet_rom( .addr(addr), .data(data));

    
    // Output colors to VGA
    assign VGA_R = Red;
    assign VGA_G = Green;
    assign VGA_B = Blue;
    always_comb
	 begin
		if((DrawX >=9'd0)&&(DrawX<9'd8)&&(DrawY<9'd15))
			addr = (DrawY + 16 * 'h13);
		else if((DrawX >=9'd8)&&(DrawX<9'd16)&&(DrawY<9'd16))
			addr = (DrawY + 16 * 'h03);
		else if((DrawX >=9'd16)&&(DrawX<9'd24)&&(DrawY<9'd16))
			addr = (DrawY + 16 * 'h0f);
		else if((DrawX >=9'd24)&&(DrawX<9'd32)&&(DrawY<9'd16))
			addr = (DrawY + 16 * 'h12);
		else if((DrawX >=9'd32)&&(DrawX<9'd40)&&(DrawY<9'd16))
			addr = (DrawY + 16 * 'h05);
		else if((DrawX >=9'd40)&&(DrawX<9'd48)&&(DrawY<9'd16))
			addr = 0;
		else if((DrawX >=9'd48)&&(DrawX<9'd56)&&(DrawY<9'd16))
			addr = (DrawY + 16 * ('h1b + score/10));
		else if((DrawX >=9'd56)&&(DrawX<9'd64)&&(DrawY<9'd16))
			addr = (DrawY + 16 * ('h1b + score%10));
			
			
			
		else if((DrawX >=9'd0)&&(DrawX<9'd8)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY- 16 + 16 * ('h14));
		else if((DrawX >=9'd8)&&(DrawX<9'd16)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h0f));	
		else if((DrawX >=9'd16)&&(DrawX<9'd24)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h10));
		else if((DrawX >=9'd24)&&(DrawX<9'd32)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h1b+'h03));
			
		else if((DrawX >=9'd32)&&(DrawX<9'd40)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = 0;
		else if((DrawX >=9'd40)&&(DrawX<9'd48)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h1b + score1/10));
		else if((DrawX >=9'd48)&&(DrawX<9'd56)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h1b + score1%10));
			
		else if((DrawX >=9'd56)&&(DrawX<9'd64)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = 0;
		else if((DrawX >=9'd64)&&(DrawX<9'd72)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h1b + score2/10));
		else if((DrawX >=9'd72)&&(DrawX<9'd80)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h1b + score2%10));
		
		else if((DrawX >=9'd80)&&(DrawX<9'd88)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = 0;
		else if((DrawX >=9'd88)&&(DrawX<9'd96)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h1b + score3/10));
		else if((DrawX >=9'd96)&&(DrawX<9'd104)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
			addr = (DrawY-16 + 16 * ('h1b + score3%10));
			
		else
			addr = 0;
	 end
    // Assign color based on is_ball signal
    always_comb
    begin
			
        if ((DrawX >= 9'd200) && (DrawX < 9'd400) && (DrawY < 9'd400)) 
        begin
				if (block_map[DrawY/20][(DrawX - 9'd200)/20])
				begin
					Red = color_data[23:16];
					Green = color_data[15:8];
					Blue = color_data[7:0];
				end
				else
				begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
        end
		  else if ((DrawX >= 9'd400) && (DrawX < 9'd480) && (DrawY < 9'd80)) 
        begin
				if (block_keep[DrawY/20][(DrawX - 9'd400)/20])
				begin
					Red = color_data[23:16];
					Green = color_data[15:8];
					Blue = color_data[7:0];
				end
				else
				begin
					Red = 8'h00;
					Green = 8'h00;
					Blue = 8'h00;
				end
        end
		  else if((DrawX >=9'd0)&&(DrawX<9'd64)&&(DrawY<9'd16))
		  begin
				if(data[7-DrawX%8] == 1)
				begin
					Red = 8'h00;
					Green = 8'hff;
					Blue = 8'hff;
				end
				else
				begin
					Red = 8'h3f; 
					Green = 8'h00;
					Blue = 8'h7f - {1'b0, DrawX[9:3]};
				end
		  end
		  else if((DrawX >=9'd0)&&(DrawX<9'd104)&&(DrawY >= 9'd16)&&(DrawY<9'd32))
		  begin
				if(data[7-DrawX%8] == 1)
				begin
					Red = 8'h00;
					Green = 8'hff;
					Blue = 8'hff;
				end
				else
				begin
					Red = 8'h3f; 
					Green = 8'h00;
					Blue = 8'h7f - {1'b0, DrawX[9:3]};
				end
		  end
        else 
        begin
            // Background with nice color gradient
            Red = 8'h3f; 
            Green = 8'h00;
            Blue = 8'h7f - {1'b0, DrawX[9:3]};
        end
    end 
    
endmodule
