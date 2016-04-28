module vector_delay(x_vec_plus, x_vec_minus, clk, STATE, master_cnt, x_plus_chosen, x_minus_chosen, enable,fix_next_state, asyn_reset,comp_cycle);



parameter UNROLLING= 4;
parameter RAM_ADDR_WIDTH=7;
parameter START=3'd0;
parameter WRITE_IN=3'd1;
parameter READ_OUT=3'd2;
parameter READ_OUT_LAST_LINE=3'd3;
parameter END=3'd4;


input clk;
input enable;
input asyn_reset;
input [2:0] STATE;
input[RAM_ADDR_WIDTH+2-1:0] master_cnt;
input [RAM_ADDR_WIDTH-1:0] comp_cycle;

input[(UNROLLING-1):0] x_vec_plus, x_vec_minus;
output[(UNROLLING-1):0] x_plus_chosen, x_minus_chosen;

input fix_next_state;
reg[(UNROLLING-1):0] x_plus_delayed, x_minus_delayed;
reg[(UNROLLING-1):0] x_plus_chosen, x_minus_chosen;
/*
always @ (posedge clk or posedge asyn_reset) begin 
	if (asyn_reset == 1) begin
		fix_next_state <= 0;
	end
	else begin
		if (enable == 1) begin
			if (STATE == WRITE_IN) begin
				fix_next_state <= 1;
			end
			if (fix_next_state == 1) begin
				fix_next_state <= 0;
			end
		end
	end	
end
*/
	

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset == 1) begin
		x_plus_delayed <= 0;
		x_minus_delayed <= 0;
	end
	else begin
	//	if (STATE == START) begin
			x_plus_delayed <= x_vec_plus;
			x_minus_delayed <= x_vec_minus;
	//	end
	end
end


always @ (*) begin
	if(fix_next_state == 1 || master_cnt < 4)begin
		/*case (master_cnt [1:0])
			2'b01: begin
				x_plus_delayed <= {1'b0, x_vec_plus [2:0]};
				x_minus_delayed <= {1'b0, x_vec_minus [2:0]};
			end
			2'b10: begin
				x_plus_delayed <= {x_vec_plus[3],1'b0,x_vec_plus[1:0]};
				x_minus_delayed <= {x_vec_minus[3],1'b0,x_vec_minus[1:0]};
			end
			2'b11: begin
				x_plus_delayed <= {x_vec_plus[3:2],1'b0,x_vec_plus[0]};
				x_minus_delayed <= {x_vec_minus[3:2],1'b0,x_vec_minus[0]};
			end
			2'b00: begin
				x_plus_delayed <= {x_vec_plus[3:1],1'b0};
				x_minus_delayed <= {x_vec_minus[3:1],1'b0};
			end
			default: begin
				x_plus_delayed <= x_vec_plus;
				x_minus_delayed <= x_vec_minus;
			end
		endcase*/
		x_plus_chosen <= x_plus_delayed;
		x_minus_chosen <= x_minus_delayed;
	end
	else begin 
	/*
		x_plus_delayed <= x_vec_plus;
		x_minus_delayed <= x_vec_minus;
	*/
		x_plus_chosen <= x_vec_plus;
		x_minus_chosen <= x_vec_minus;
	end
end

endmodule
