module Multiplier_hd (
x_value,
y_value,
p_value,
clk,
asyn_reset,
data_x_vld,
data_x_rdy,
data_y_vld,
data_y_rdy,
data_out_vld,
data_out_rdy);

parameter RAM_ADDR_WIDTH=7;
parameter UNROLL_WIDTH = 4;
parameter UPPER_BITS= 5;

input [1:0] x_value,y_value;
output [1:0] p_value;
input clk;
input asyn_reset; 

// input handshake config
input data_x_vld,data_y_vld;
output data_x_rdy,data_y_rdy;
input data_out_rdy;
output data_out_vld;

wire [RAM_ADDR_WIDTH+2-1:0] master_cnt;
wire [RAM_ADDR_WIDTH-1:0] comp_cycle,rd_addr_res,wr_addr_res;
wire [RAM_ADDR_WIDTH-1:0] rd_addr;
wire [UNROLL_WIDTH-1:0] x_plus, x_minus, y_plus, y_minus;
wire [UNROLL_WIDTH-1:0] x_plus_delayed, x_minus_delayed;
wire enable_all,wr_enable;
wire enable_cnt;
wire enable_shift;
wire [1:0] carry_out_control;
wire [2:0] STATE;
wire [1:0] x_value_reg,y_value_reg;
wire [UNROLL_WIDTH-1:0] x_plus_sel, x_minus_sel, y_plus_sel, y_minus_sel;
wire [UNROLL_WIDTH-1:0] res_plus, res_minus;
wire [1:0] shift_to_upper;
wire [1:0] cout_to_Vreg_one,cout_to_Vreg_two;
wire enable_V_reg;
wire fix_next_state;
wire[1:0] p_value_reg;
wire enable_shift_upper;
wire borrow_in_upper;
//wire [UPPER_BITS-1:0] res_upper_plus, res_upper_minus, v_out_plus, v_out_minus;

// Section one
//Append logic, SDVM and FSM control logic
computation_control_hd FSM(
x_value,
y_value,
p_value,
master_cnt,
clk,
comp_cycle,
rd_addr,
rd_addr_res,
wr_addr_res,
wr_enable,
STATE,
enable_all,
enable_cnt,
carry_out_control,
enable_V_reg,
enable_shift_upper,
enable_shift,
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
p_value_reg);


generate_CA_reg_hd CA_reg(comp_cycle,rd_addr,x_value_reg,y_value_reg,x_plus,x_minus,y_plus,y_minus,clk,master_cnt,enable_all,wr_enable,asyn_reset);

vector_delay x_delay(x_plus, x_minus, clk, STATE, master_cnt, x_plus_delayed, x_minus_delayed, enable_all,fix_next_state,asyn_reset,comp_cycle);

SDVM SDVM1(clk,x_plus_delayed, x_minus_delayed, y_value_reg, x_plus_sel, x_minus_sel, enable_all, asyn_reset);

SDVM SDVM2(clk,y_plus, y_minus, x_value_reg, y_plus_sel, y_minus_sel, enable_all, asyn_reset);

counter master_counter(enable_cnt,clk,master_cnt,asyn_reset);

// Section one completed 
res_control res_block(
clk,
x_plus_sel,
x_minus_sel,
y_plus_sel,
y_minus_sel,
res_plus,
res_minus,
comp_cycle,
rd_addr_res,
wr_addr_res,
carry_out_control,
cout_to_Vreg_one,
cout_to_Vreg_two,
shift_to_upper, 
borrow_in_upper,
enable_all,
enable_shift, 
enable_shift_upper,
asyn_reset);

V_upper_bits_control V_reg(cout_to_Vreg_one, cout_to_Vreg_two, shift_to_upper,borrow_in_upper, clk, enable_shift_upper ,enable_V_reg, asyn_reset, p_value_reg);




endmodule
