module square_wave_display_vga_v1_0_top (
	input clk,    // Clock
	input [2:0] key,
	input reset_n,  // Asynchronous reset active low
	output logic vga_hsync,vga_vsync,
	output logic [2:0] vga_rgb
);

logic [9:0] pixel_x,pixel_y;
logic video_on;
logic [2:0] rgb;

vga_sync vga_sync_inst
(
	.clk(clk), .rst_n(reset_n), .hsync(vga_hsync),.vsync(vga_vsync),
	.pixel_x(pixel_x),.pixel_y(pixel_y),.video_on(video_on)
);

square_wave_display_vga_gen square_wave_display_vga_gen_inst
(
	.clk(clk),
	.reset_n(reset_n),
	.key(key),
	.pixel_x(pixel_x),
	.pixel_y(pixel_y),
	.video_on(video_on),
	.rgb(vga_rgb)
);

endmodule : square_wave_display_vga_v1_0_top