module comp_v_value(
clk,
enable,
asyn_reset,
w_plus_frac,
w_minus_frac,
x_value,
q_plus_vec,
q_minus_vec,
v_plus_frac,
v_minus_frac,
cin_one,
cin_two,
cout_one,
cout_two,
compare
);

parameter unrolling = 64;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 6;

input clk;
input enable;
input asyn_reset;
input [unrolling - 1 : 0] w_plus_frac, w_minus_frac, q_plus_vec, q_minus_vec;
input [1:0] x_value, cin_two, cin_one;

output [unrolling - 1 : 0] v_plus_frac, v_minus_frac;
output [1:0] cout_one, cout_two;
output compare;

wire [unrolling -1 :0] x_plus_vec, x_minus_vec;

four_bits_parallel_adder adder_v(
w_plus_frac,
w_minus_frac,
~q_plus_vec,
~q_minus_vec,
x_plus_vec,
x_minus_vec,
v_plus_frac,
v_minus_frac,
cin_one,
cin_two,
cout_one,
cout_two,
compare);
defparam adder_v.bits = unrolling;

assign x_plus_vec = (rd_addr) ? {x_value[1],63'b0} : 0; 
assign x_minus_vec = (rd_addr) ? {x_value[0],63'b0} : 0;
assign compare = (v_plus_frac >= v_minus_frac) ? (1):(0);

endmodule




