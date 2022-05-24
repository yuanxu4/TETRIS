//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------


module ece385_finalproject( input               CLOCK_50,
             input        [3:0]  KEY,          //bit 0 is set up as Reset
             output logic [6:0]  HEX0, HEX1,
             // VGA Interface 
             output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
             output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
             // CY7C67200 Interface
             inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
             output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
             output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
             input               OTG_INT,      //CY7C67200 Interrupt
             // SDRAM Interface for Nios II Software
             output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
             inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
             output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
             output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
             output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,      //SDRAM Clock
											
											
				 input AUD_ADCDAT,
				 input AUD_DACLRCK,
				 input AUD_ADCLRCK,
				 input AUD_BCLK,
				 output logic AUD_DACDAT,
				 output logic AUD_XCK,
				 output logic I2C_SCLK,
				 output logic I2C_SDAT
                    );
    
    logic Reset_h, Clk;
    logic [7:0] keycode;
	 int address;
	 logic [23:0] color_data;
    
    assign Clk = CLOCK_50;
    always_ff @ (posedge Clk) begin
        Reset_h <= ~(KEY[0]);        // The push buttons are active low
    end
    logic is_block;
	 logic [9:0] DrawX, DrawY;
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
	 logic [19:0][9:0] block_map;
	 logic [2:0] randnum_b;
	 logic new_block, go_down, go_right, go_left, switch, clear, gg, touched, fast_down,go_next,clearall,record;
	 logic [3:0][3:0] block_keep;
	 logic [10:0]        score,score1,score2,score3;
	 
	 logic INIT,data_over,INIT_FINISH;
	 logic [16:0]Add;
	 logic [16:0]music_content;
	 logic adc_full;
	 
	 audio_interface music ( .LDATA (music_content),
									 .RDATA (music_content),
									 .Clk(Clk),
									 .Reset(Reset_h),
									 .INIT(INIT),
									 .INIT_FINISH(INIT_FINISH),
									 .adc_full (adc_full),
									 .data_over(data_over),
									 .AUD_MCLK(AUD_XCK),
									 .AUD_BCLK(AUD_BCLK),
									 .AUD_ADCDAT(AUD_ADCDAT),
									 .AUD_DACDAT(AUD_DACDAT),
									 .AUD_DACLRCK(AUD_DACLRCK),
									 .AUD_ADCLRCK(AUD_ADCLRCK),
									 .I2C_SDAT(I2C_SDAT),
									 .I2C_SCLK(I2C_SCLK),
									 .ADCDATA(ADCDATA),
									 
	 );
	 audio Audio_istance (.*, .Reset(Reset_h));
	 
	 music music_instance(.*);
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(Clk),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
     // You need to make sure that the port names here match the ports in Qsys-generated codes.
     ece385_finalproject_soc nios_system(
                             .clk_clk(Clk),         
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset)
    );
    
    // Use PLL to generate the 25MHZ VGA_CLK.
    // You will have to generate it on your own in simulation.
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));
    
    // TODO: Fill in the connections for the rest of the modules 
    VGA_controller vga_controller_instance(.Clk, 
														 .Reset(Reset_h), 
														 .VGA_HS, 
														 .VGA_VS,
														 .VGA_CLK,
														 .VGA_BLANK_N,
														 .VGA_SYNC_N,
														 .DrawX,
														 .DrawY);
    
    // Which signal should be frame_clk?
								
//	 block block_instance(    .Clk,                // 50 MHz clock
//                             .Reset(Reset_h),              // Active-high reset signal
//                             .frame_clk(VGA_VS),          // The clock indicating a new frame (~60Hz)
//									  .DrawX, 
//									  .DrawY,       // Current pixel coordinates
//									  .address,
//									  .is_block             // Whether current pixel belongs to ball or background
//              );
	block_address block_address0( .DrawX, 
											.DrawY,       // Current pixel coordinates
											.address);   
    
    color_mapper color_instance( .color_data,
											.block_map,
											.block_keep,
											.DrawX,
											.DrawY,
											.score,
											.score1,
											.score2,
											.score3,
											.VGA_R,
											.VGA_G,
											.VGA_B);
											
	 block_state  block_state0 (  .Clk,                  
											.Reset(Reset_h),              	
					                  .touched,
											.gg, 
											.keycode,
											.new_block,
											.go_down,
											.fast_down,
											.go_right,
											.go_left,
											.go_next,
											.switch,
											.clear,
											.clearall);
											
	 block_display block_display0 (	.Clk,                
												.Reset(Reset_h),
												.new_block,
												.go_down,
												.fast_down,
												.go_right,
												.go_next,
												.go_left,
												.switch,
												.clear,
												.clearall,
												.gg,
												.touched,
												.record,
												.randnum_b,
												.block_keep,
												.block_map,
												.score);
												
	random 			random0			(	.Clk,
												.frame_clk(VGA_CLK),
												.Reset(Reset_h),
												.randnum_b
	);
	rank rank0(             .Clk,         // 50 MHz clock
                           .Reset(Reset_h),
									.score,
									.record,
									.score1,
									.score2,
									.score3);
											
	 frameROM   ROM_instance(.address,
									 .Clk,
									 .color_data);
    
    // Display keycode on hex display
    HexDriver hex_inst_0 (score[3:0], HEX0);
    HexDriver hex_inst_1 (score[7:4], HEX1);

    
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
endmodule
