module square_wave_display_vga_gen
(
	input clk,reset_n,
	input [2:0] key,
	input [9:0] pixel_x,pixel_y,
	input video_on,
	output [2:0] rgb

);
logic key_0_tick, key_1_tick, key_2_tick;
logic [1:0] din_reg;
logic [1:0] dout;
logic on;
logic [7:0] font_data;
logic font_bit;
logic cursor_on,underline_on;
logic [2:0] y_cursor_reg,y_cursor_next;
logic [6:0] x_cursor_reg,x_cursor_next;
logic [9:0] pixel_x_reg[1:0], pixel_y_reg[1:0];

always_ff @(posedge clk or negedge reset_n) begin : proc_regs
	if(!reset_n) begin
		y_cursor_reg <= '0;
		x_cursor_reg <= '0;
		pixel_x_reg[0] <= '0;
		pixel_x_reg[1] <= '0;
		pixel_y_reg[0] <= '0;
		pixel_y_reg[1] <= '0;
		din_reg<=0;
	end else begin
		y_cursor_reg <=y_cursor_next;
		x_cursor_reg <=x_cursor_next;
		pixel_x_reg[0] <=pixel_x;
		pixel_x_reg[1] <=pixel_x_reg[0];
		pixel_y_reg[0] <=pixel_y;
		pixel_y_reg[1] <=pixel_y_reg[1];
		din_reg<=key_2_tick? din_reg+1:din_reg;
	end
end

always_comb begin : proc_cursor_next
	x_cursor_next = x_cursor_reg;
	y_cursor_next = y_cursor_reg;
	if(key_0_tick) x_cursor_next = (x_cursor_reg<80)? x_cursor_reg+1 : 0;
	if(key_1_tick) y_cursor_next = (y_cursor_reg<7)? y_cursor_reg+1 : 0;
end

assign font_bit = on && font_data[~pixel_x_reg[1][2:0]];
assign cursor_on = pixel_y_reg[1][8:6]==y_cursor_reg &&
pixel_x_reg[1][9:3]==x_cursor_reg;

assign underline_on = cursor_on && (pixel_y_reg[1][5:0]>=60);

always_comb begin : proc_rgb
	rgb= '0;
	if(!video_on)
		rgb= '0;
	else if(underline_on)
		rgb= 3'b011;
	else 
		rgb= font_bit? 3'b010:3'b000;
end

db_fsm db_fsm_inst_0
(.clk(clk), .reset_n(reset_n), .sw(!key[0]), 
	 .db_tick(key_0_tick));

db_fsm db_fsm_inst_1
(.clk(clk), .reset_n(reset_n), .sw(!key[1]), 
	 .db_tick(key_1_tick));

db_fsm db_fsm_inst_2
(.clk(clk), .reset_n(reset_n), .sw(!key[2]), 
	 .db_tick(key_2_tick));

dual_port_sync_ram #(.ADDR_WIDTH(10),.DATA_WIDTH(3)) dual_port_syn_ram_inst
(
	.clk(clk),
	.we('1),
	.din({1'b1,din_reg}), //write data
	.addr_a({y_cursor_reg,x_cursor_reg}), //write addr
	.addr_b({pixel_y[8:6],pixel_x[9:3]}), //read addr
	.dout_a(),
	.dout_b({on,dout}) //read data	
);

square_wave_rom square_wave_rom_inst
(
	.clk(clk), 
	.addr({dout,pixel_y[5:0]}),
	.data(font_data)
);

endmodule : square_wave_display_vga_gen