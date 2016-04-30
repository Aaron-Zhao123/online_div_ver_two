module v_frac_logic(
q_plus_vec,
q_minus_vec,
w_plus_frac,
w_minus_frac,
x_value,
rd_addr,
shift_to_int_plus,
shift_to_int_minus,
compare_frac
);

parameter unrolling = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 6;

input [1:0] x_value;
input [unrolling - 1 :0] q_plus_vec, q_minus_vec, w_plus_frac, w_minus_frac;
output [1:0] shift_to_int_plus, shift_to_int_minus;
output compare_frac;

wire [unrolling - 1 : 0] tmp_plus_vec, tmp_minus_vec;
wire [1:0] cin_one, cout_one;

four_bits_adder add(
~q_plus_vec,
~q_minus_vec,
w_plus_frac,
w_minus_frac,
tmp_plus_vec,
tmp_minus_vec,
cin_one,
cout_one
);
defparam add.bits = unrolling;

assign shift_to_int_plus = cout_one[1] + x_value[1];
assign shift_to_int_minus = cout_one[0] + x_value[0];

assign compare_frac = ({shift_to_int_plus, tmp_plus_vec} >= {shift_to_int_minus,tmp_minus_vec})? 0:1; 
endmodule

module v_int_logic(
shift_to_int_plus,
shift_to_int_minus,
w_plus_int,
w_minus_int,
v_int_plus,
v_int_minus,
q_value
);

parameter unrolling = 64;
parameter upper_width = 4; 
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 6;

input [2:0] shift_to_int_plus, shift_to_int_minus;
input [UPPER_WIDTH-1:0] w_plus_int, w_minus_int;
output [UPPER_WIDTH-1:0] v_int_plus, v_int_minus;
output [1:0] q_value;
wire [UPPER_WIDTH-1:0] v_value;

assign v_int_plus = w_plus_int + shift_to_int_plus;
assign v_int_minus = w_minus_int + shift_to_int_minus;
assign v_value = v_int_plus - v_int_minus;

always @ (*) begin
	case (v_value[UPPER_WIDTH-1:UPPER_WIDTH-4])
		4'b0111: q_value <= 2'b10;
		4'b0110: q_value <= 2'b10;
		4'b0101: q_value <= 2'b10;
		4'b0100: q_value <= 2'b10;
		4'b0011: q_value <= 2'b10;
		4'b0010: q_value <= 2'b10;
		4'b0001: q_value <= 2'b10;
		4'b0000: q_value <= 2'b00;
		4'b1111: q_value <= 2'b00;
		4'b1110: q_value <= 2'b01;
		4'b1101: q_value <= 2'b01;
		4'b1100: q_value <= 2'b01;
		4'b1011: q_value <= 2'b01;
		4'b1010: q_value <= 2'b01;
		4'b1001: q_value <= 2'b01;
		4'b1000: q_value <= 2'b01;
	endcase
end

endmodule
