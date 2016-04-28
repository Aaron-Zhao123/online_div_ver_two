module Divider_v2(
x_value,
d_value,
clk,
asyn_reset,
enable_all,
q_value
);

input [1:0] x_value, d_value;
input clk;
input asyn_reset;
input enable_all;

output [1:0] q_value;

parameter unrolling = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 6;

wire [1:0] x_value_comp, d_value_comp;
wire refresh;
wire [10:0] counter, shift_cnt;
wire enable;
wire [unrolling-1:0] d_plus_vec, d_minus_vec;
wire [unrolling-1:0] q_plus_vec, q_minus_vec;
wire [unrolling-1:0] v_plus_frac, v_minus_frac, w_plus_frac, w_minus_frac;
wire [UPPER_WIDTH-1:0] v_plus_int, v_minus_int, w_plus_int, w_minus_int;
wire [ADDR_WIDTH-1:0] wr_addr, rd_addr;
wire [1:0] q_value_comp;

computation_control_v2 comp(
clk,
q_value,
d_value,
enable_all,
counter,
shift_cnt,
wr_addr,
rd_addr,
asyn_reset,
enable,
add_enable,
res_enable,
refresh,
x_value_comp,
d_value_comp
);

generate_d_reg CA_d_reg(
enable,
refresh,
asyn_reset,
clk,
d_value_comp,
d_plus_vec,
d_minus_vec,
wr_addr,
counter,
shift_cnt
);

generate_q_reg CA_q_reg(
enable,
refresh,
asyn_reset,
clk,
q_value_comp,
q_plus_vec,
q_minus_vec,
wr_addr,
counter,
shift_cnt
);


endmodule


