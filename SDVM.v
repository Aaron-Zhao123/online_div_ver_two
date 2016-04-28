module SDVM(clk,vec_in_plus,vec_in_minus, digit_select, vec_out_plus,vec_out_minus,enable,asyn_reset);

input enable;
input clk;
input asyn_reset;
parameter Num_bits=4;
input [Num_bits-1:0] vec_in_plus,vec_in_minus;
input[1:0] digit_select; 
output [Num_bits-1:0] vec_out_plus,vec_out_minus;
reg [Num_bits-1:0] vec_out_plus,vec_out_minus;

//tmp_two_cycle_delay,tmp_three_cycle_delay;
wire[1:0] digit_select_delayed;
//reg[2:0] detect;
//reg signal;



D_FF_two_bits D1(digit_select,digit_select_delayed,clk,enable,asyn_reset);




	
always@* begin
	if (asyn_reset) begin
		vec_out_plus <= 4'b0;
		vec_out_minus <= 4'b0;
	end
	else begin
		case(digit_select_delayed)
			2'b00: begin
				vec_out_plus<=4'b0;
				vec_out_minus<=4'b0;
			end
			2'b10: begin 
				vec_out_plus<=vec_in_plus;
				vec_out_minus<=vec_in_minus;//if digit is 1
			end
			2'b01: begin
				vec_out_plus<=~vec_in_plus;
				vec_out_minus<=~vec_in_minus;//if digit is -1
			end
			default: begin 
				vec_out_plus<=4'b0;
				vec_out_minus<=4'b0;
			end
		endcase
	end
end

endmodule
