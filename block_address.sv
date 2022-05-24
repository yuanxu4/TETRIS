module  block_address ( input [9:0]   DrawX, DrawY,       // Current pixel coordinates
								output int    address
							 );   
    always_comb begin
           address = (DrawY%20) * 20 + (DrawX%20);
	 end
    
endmodule
