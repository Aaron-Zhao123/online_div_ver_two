module D_FF_two_bits(in,out,clk,enable,asyn_reset);

input clk;
input enable;
input asyn_reset;
input[1:0] in;
output[1:0] out;
reg[1:0] out;


always@(posedge clk or posedge asyn_reset) begin
	if (asyn_reset == 1) begin
		out <= 0;
	end
	else begin
		if(enable==1'b1) begin
			out<=in;
		end
	end
end

endmodule
