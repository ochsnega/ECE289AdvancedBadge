module advancedBadgeMain(
	input clk, // Button 0
	input rst, // Button 1
	input start, // Button 2
	input g_control, // SW 0
	input [4:0] r_control, // SW 5-1
	input core_control, // SW 17
	output reg which_core, // LED G 8
	output reg [6:0] g_out, // LED G 6-0
	output reg [15:0] r_out, // LED R 15-0
	output reg reg_w_en, // LED R 16
	output reg mem_wren, // LED R 17
	output reg has_lock // LED G 7
);

// Instantiate Memory
wire [7:0] core_1_mem_add;
wire [7:0] core_2_mem_add;
wire [31:0] core_1_mem_data;
wire [31:0] core_2_mem_data;
wire core_1_mem_wren;
wire core_2_mem_wren;
wire [31:0] core_1_mem_out;
wire [31:0] core_2_mem_out;
mem my_mem(core_1_mem_add, core_2_mem_add, clk, core_1_mem_data, core_2_mem_data, core_1_mem_wren, core_2_mem_wren, core_1_mem_out, core_2_mem_out);

// Instantiate Arbiter
wire arb_core_1_in;
wire arb_core_2_in;
wire arb_core_1_out;
wire arb_core_2_out;
arbiter my_arbiter(clk, rst, arb_core_1_in, arb_core_2_in, arb_core_1_out, arb_core_2_out);

// Instantiate Core 1
/*
module core(
	input clk, // Button 0
	input rst, // Button 1
	input start, // Button 2
	input g_control, // SW 0
	input [4:0] r_control, // SW 5-1
	input locked, // Is arbiter locked?
	input [31:0] mem_out,
	output reg ask_for_lock, // Ask arbiter to lock memory
	output reg [6:0] g_out, // LED G 6-0
	output reg [15:0] r_out, // LED R 15-0
	output reg reg_w_en, // LED R 17
	output reg mem_wren, // LED R 16
	output reg [7:0] mem_address,
	output reg [31:0] mem_data
);
*/
wire [6:0] core_1_g_out;
wire [15:0] core_1_r_out;
wire core_1_reg_w_en;
core my_core_1(clk, rst, start, g_control, r_control, arb_core_1_out, core_1_mem_out, arb_core_1_in, core_1_g_out, core_1_r_out, core_1_reg_w_en, core_1_mem_wren, core_1_mem_add, core_1_mem_data);

// Instantiate Core 2
wire [6:0] core_2_g_out;
wire [15:0] core_2_r_out;
wire core_2_reg_w_en;
core my_core_2(clk, rst, start, g_control, r_control, arb_core_2_out, core_2_mem_out, arb_core_2_in, core_2_g_out, core_2_r_out, core_2_reg_w_en, core_2_mem_wren, core_2_mem_add, core_2_mem_data);

always@(*)
begin
case(core_control)
	1'b0:
	begin
		which_core = 1'b0;
		g_out = core_1_g_out;
		r_out = core_1_r_out;
		reg_w_en = core_1_reg_w_en;
		mem_wren = core_1_mem_wren;
		has_lock = arb_core_1_out;
	end
	1'b1:
	begin
		which_core = 1'b1;
		g_out = core_2_g_out;
		r_out = core_2_r_out;
		reg_w_en = core_2_reg_w_en;
		mem_wren = core_2_mem_wren;
		has_lock = arb_core_2_out;
	end
endcase
end

endmodule 