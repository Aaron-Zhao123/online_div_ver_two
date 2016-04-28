module comp_v_frac(
clk,
enable,
asyn_reset,
w_plus_int,
w_minus_int,
q_plus_int,
q_minus_int,
v_plus_int,
v_minus_int,
q_value,
cin_one,
cin_two,
compare_frac
);

parameter unrolling = 64;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 6;

input clk;
input enable;
input asyn_reset;
input [UPPER_WIDTH-1:0] w_plus_int, w_minus_int, q_plus_int, q_minus_int;
input [1:0] cin_one, cin_two;
input compare_frac;

output [UPPER_WIDTH-1:0] v_plus_int, v_minus_int;
output compare_frac;

wire [1:0] cout_one, cout_two;

four_bits_parallel_adder adder_v_int(
w_plus_int,
w_minus_int,
~q_plus_int,
~q_minus_int,
0,
0,
v_plus_int,
v_minus_int,
cin_one,
cin_two,
cout_one,
cout_two,
compare);
defparam adder_v_int = UPPER_WIDTH;

always @ (*) begin
	
end

endmodule



