module computation_control_hd(
x_value,
y_value,
p_value,
cnt_master,
clk,
computation_cycle,
rd_addr,
rd_addr_res,
wr_addr_res,
write_enable,
STATE,
enable_all,
enable_cnt,
carry_out_control,
enable_V_reg,
enable_shift_upper,
enable_shfit,
fix_next_state,
asyn_reset,
data_x_vld,
data_x_rdy,
data_y_vld,
data_y_rdy,
data_out_vld,
data_out_rdy,
x_value_reg,
y_value_reg,
p_value_reg
);

parameter RAM_ADDR_WIDTH=7;
// this block computes the cycles which are at computation at the moment
// also provides enable for Multiplier to know when to fetch from outside input data and also controls writing to the CA_RAM

//testing
// finished

input[RAM_ADDR_WIDTH+2-1:0] cnt_master;
input clk;
input asyn_reset;
input [1:0] x_value, y_value; 
input [1:0] p_value_reg;
output[RAM_ADDR_WIDTH - 1:0] computation_cycle;// this would always be the address
output write_enable;
output[2:0] STATE;
output enable_all;
output enable_cnt;
output[1:0] carry_out_control; // if 0, stop; if 1, loop adder; if 2, send cout to Vreg
output enable_shfit;
output [1:0] x_value_reg, y_value_reg;
output enable_V_reg;
output enable_shift_upper;
output fix_next_state;
//handshake protocool
input data_x_vld,data_y_vld;
input data_out_rdy;
output data_x_rdy,data_y_rdy;
output data_out_vld;
output [1:0] p_value;
output [RAM_ADDR_WIDTH -1 :0] rd_addr;
output [RAM_ADDR_WIDTH -1 :0] rd_addr_res,wr_addr_res;

wire[RAM_ADDR_WIDTH -1 :0] cycle_num;
//wire[1:0] remainder;
reg[6:0] computation_cycle;
reg hd_x,hd_y,hd_z;
reg [2:0] STATE;
reg data_x_rdy,data_y_rdy,data_out_vld;
reg enable_all, enable_cnt, enable_carry_out;
reg[1:0] x_value_reg, y_value_reg;
reg[1:0] carry_out_control;
reg enable_V_reg;
reg enable_shfit;
reg fix_next_state;
reg [1:0] p_value;
reg enable_shift_upper;
reg[RAM_ADDR_WIDTH -1 :0] rd_addr;
reg[RAM_ADDR_WIDTH -1 :0] rd_addr_res,wr_addr_res;


parameter START=3'd0;
parameter WRITE_IN=3'd1;
parameter READ_OUT=3'd2;
parameter READ_OUT_LAST_LINE=3'd3;
parameter END=3'd4;

reg write_enable;
initial begin
	computation_cycle <= 0;
	write_enable <= 0;
	STATE <= START;
	fix_next_state <= 0; 
end

assign cycle_num=cnt_master[RAM_ADDR_WIDTH+2-1:2];
//assign remainder=cnt_master[1:0];


// STATE control

always@(posedge clk or posedge asyn_reset) begin
	if (asyn_reset == 1) begin
		STATE <= START;
		hd_x <= 0;
		hd_y <= 0;
		hd_z <= 0;
		computation_cycle <= 0;
		x_value_reg <= 0;
		y_value_reg <= 0;
		enable_shfit <= 0;
		fix_next_state <= 0;
		p_value<= 0;
		rd_addr_res <= 0;
		wr_addr_res <= 0;
	end
	else begin
		case(STATE)
			START : begin
				if (hd_x == 1 && hd_y == 1) begin
					STATE <= WRITE_IN;
					hd_x <= 0;
					hd_y <= 0;
					computation_cycle <= cycle_num;
					rd_addr_res <= cycle_num;
					wr_addr_res <= cycle_num;
					x_value_reg <= x_value; // if hd succeed, refresh x,y values
					y_value_reg <= y_value;
					enable_shfit <= 0; 
					fix_next_state <= 0;
				end
				
				if (data_x_rdy && data_x_vld) begin
					hd_x <= 1; 
				end
				
				if (data_y_rdy && data_y_vld) begin
					hd_y <= 1;
				end
			end
			WRITE_IN: begin		// this always take one cycle to write only
				if (computation_cycle == 0) begin
					STATE <= READ_OUT_LAST_LINE;
					enable_shfit <= 0;
					fix_next_state <= 1;
					rd_addr_res <= cycle_num;
					wr_addr_res <= cycle_num;

				end
				else begin
					STATE <= READ_OUT;
					computation_cycle <= computation_cycle - 7'b1;
					rd_addr_res <= computation_cycle -7'b1;
					wr_addr_res <= computation_cycle;
					enable_shfit <= 1;
					fix_next_state <= 1;
				end
			end
			READ_OUT: begin
				if (computation_cycle == 0) begin
					STATE <= READ_OUT_LAST_LINE;
					enable_shfit <= 0;
					fix_next_state <= 0;
					rd_addr_res <= 0;
					wr_addr_res <= 0;
				end
				else begin 
					computation_cycle <= computation_cycle - 7'b1;
					rd_addr_res <= rd_addr_res -7'b1;
					wr_addr_res <= wr_addr_res -7'b1;
					fix_next_state <= 0;
				end
			end
			READ_OUT_LAST_LINE : begin
				STATE <= END;
				enable_shfit <= 0;
				fix_next_state <= 0;
				p_value <= p_value_reg;
				rd_addr_res <= 0;
				wr_addr_res <= 0;

			end
			END: begin
				if (data_out_vld && data_out_rdy) begin
					hd_z <= 1;
				end
				if (hd_z == 1) begin
					hd_z <= 1'b0;
					STATE <= START;
					enable_shfit <= 0;
					fix_next_state <= 0;
				end
			end
			default : begin
				STATE <= START;
			end
		endcase	
	end
end


always @ (*) begin
	if (asyn_reset == 1) begin
		data_x_rdy <= 0;
		data_y_rdy <= 0;
		enable_all <= 0;
		write_enable <= 0;
		data_out_vld <= 0;
		enable_cnt <= 0;
		carry_out_control <= 0;
		enable_V_reg <= 0;
		enable_shift_upper <= 0;
		rd_addr <=0;

	end
	else begin
		case (STATE)
			START : begin
				if (hd_x == 0) begin
					data_x_rdy <= 1;
				end
				else begin
					data_x_rdy <= 0;
				end
				if (hd_y == 0) begin
					data_y_rdy <= 1;
				end
				else begin
					data_y_rdy <= 0;
				end
				if (hd_x == 1 && hd_y == 1) begin
					rd_addr <= cycle_num;
				end
				else begin
					rd_addr <= computation_cycle;
				end					
				write_enable <= 0;
				enable_all <= 0;
				data_out_vld <= 0;
				enable_cnt <= 0;
				carry_out_control <= 0;
				enable_V_reg <= 0;
				enable_shift_upper <= 0;
			end
			WRITE_IN : begin
				write_enable <= 1;
				enable_all <= 1;
				data_x_rdy <= 0;
				data_y_rdy <= 0;
				data_out_vld <= 0;
				enable_cnt <= 1;
				carry_out_control <=0; 
				enable_V_reg <= 1;
				enable_shift_upper <= 0;					
				rd_addr <= computation_cycle;
	
			end
			READ_OUT : begin
				write_enable <= 0;
				enable_all <= 1;
				data_x_rdy <= 0;
				data_y_rdy <= 0;
				data_out_vld <= 0;
				enable_cnt <= 0;
				carry_out_control <= 1;
				enable_V_reg <= 0;
				enable_shift_upper <= 0;					
				rd_addr <= computation_cycle;
	
			end
			READ_OUT_LAST_LINE : begin
				write_enable <= 0;
				enable_all <= 1;
				data_x_rdy <= 0;
				data_y_rdy <= 0;
				data_out_vld <= 0;
				enable_cnt <=0;
				carry_out_control <= 2;
				enable_V_reg <= 0;
				enable_shift_upper <= 1;					
				rd_addr <= computation_cycle;
	
			end
			END : begin
				write_enable <= 0;
				enable_all <= 0;
				data_x_rdy <= 0;
				data_y_rdy <= 0;
				enable_cnt <= 0;
				if (hd_z == 1) begin
					data_out_vld <= 0;
				end
				else begin 
					data_out_vld <= 1;
				end
				carry_out_control <= 0;
				enable_V_reg <= 0;
				enable_shift_upper <= 0;					
				rd_addr <= computation_cycle;
	
			end
			default : begin
				write_enable <= 0;
				enable_all <= 0;
				data_x_rdy <= 0;
				data_y_rdy <= 0;
				data_out_vld <= 0;
				enable_cnt <= 0;
				carry_out_control <= 0;
				enable_V_reg <= 0;
				enable_shift_upper <= 0;					
				rd_addr <= computation_cycle;
	
			end
		endcase
	end
end


endmodule
