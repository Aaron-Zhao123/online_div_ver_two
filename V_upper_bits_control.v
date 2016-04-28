module V_upper_bits_control( cout_one, cout_two, shift_in, borrow_in_upper, clk, enable_upper,enable_v_reg, asyn_reset, p_value);


parameter UPPER_BITS= 5;
//input[UPPER_BITS-1 : 0] vec_in_plus, vec_in_minus;
input clk;
input borrow_in_upper;
input [1:0] cout_one, cout_two;
input [1:0] shift_in;
input enable_upper,enable_v_reg, asyn_reset;
output [1:0] p_value;
//output [UPPER_BITS-1 : 0]vec_out_plus, vec_out_minus;

 
reg [UPPER_BITS-1 : 0] v_value_plus, v_value_minus, w_value_plus, w_value_minus, res_value_plus, res_value_minus,w_stored_plus,w_stored_minus;
reg [1:0] p_value;

wire [UPPER_BITS-1 : 0] v_upper_value;
wire [2:0] v_sample;
wire [UPPER_BITS-1 : 0] w_value; 
//wire[1:0] esti_p_value;

// V reg
always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset == 1) begin
		res_value_plus <= 0;
		res_value_minus <= 0;
		w_stored_plus <= 0;
		w_stored_minus <= 0;

	end
	else begin
		if (enable_upper == 1) begin //enable before a cycle of last read
			w_stored_plus <= w_value_plus;
			w_stored_minus <= w_value_minus;
		end
		if (enable_v_reg == 1) begin
			res_value_plus <= w_stored_plus;
			res_value_minus <= w_stored_minus;
		end
	end
end
 
always @ (*) begin

	v_value_plus <= res_value_plus + cout_one[1]+ cout_two[1];
	v_value_minus <= res_value_minus + cout_one[0]+ cout_two[0];

end
 
// V Block & SELM logic to produce pj+1
assign v_upper_value = v_value_plus - v_value_minus -borrow_in_upper; //signed representation
assign v_sample = v_upper_value [UPPER_BITS-1:UPPER_BITS-3];

//assign esti_p_value=v_value_plus[UPPER_BITS-1:UPPER_BITS-2]- v_value_minus[UPPER_BITS-1:UPPER_BITS-2];

//assign esti_p_value = v_upper_value[UPPER_BITS-1: UPPER_BITS-2];

always @* begin
	case(v_sample)
		3'b011: p_value <= 2'b10;
		3'b010: p_value <= 2'b10;
		3'b001: p_value <= 2'b10;
		3'b000: p_value <= 2'b00;
		3'b111: p_value <= 2'b00;
		3'b110: p_value <= 2'b01;
		3'b101: p_value <= 2'b01;
		3'b100: p_value <= 2'b01;
	endcase
end

// compute 2w[j+1] 


///////////////////////////////////////////////////////////////////////
// perform like the M block & shifting
always @ (*) begin
	if (v_value_plus[UPPER_BITS-2] ^v_value_minus[UPPER_BITS-2] ^ p_value[1] ^ p_value[0]) begin
			w_value_plus[UPPER_BITS-1]= v_value_plus[UPPER_BITS-2]^ p_value[1];
			w_value_minus[UPPER_BITS-1] = v_value_minus[UPPER_BITS-2]^ p_value[0];
		end
	else begin
		w_value_plus[UPPER_BITS-1]= 0;
		w_value_minus[UPPER_BITS-1] = 0;	
	end
	
	w_value_plus[UPPER_BITS-2:0] = {v_value_plus[UPPER_BITS-3:0],shift_in[1]};
	w_value_minus[UPPER_BITS-2:0] = {v_value_minus[UPPER_BITS-3:0],shift_in[0]};
end

endmodule
