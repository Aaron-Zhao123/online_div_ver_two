module V_frac_bits_v2(
clk,
enable, // a different enable
new_line,
addr,
asyn_reset,
v_plus_frac,
v_minus_frac,
w_plus_frac,
w_minus_frac
)
parameter ADDR_WIDTH=7;
parameter UPPER_WIDTH = 5;
parameter UNROLLING = 64;
input clk;
input enable;
input new_line;
input asyn_reset;
input [10:0] addr;
input [UNROLLING-1:0] v_plus_frac,v_minus_frac;

output [UNROLLING-1:0] w_plus_frac, w_minus_frac;
reg [UNROLLING-1 :0] residue_reg [2**ADDR_WIDTH-1 :0];
reg [1:0] shift_in, shift_out;

integer i;
initial begin
	for (i = 0, i< 2 ** ADDR_WIDTH-1; i = i+1) begin
		residue_reg[i] = 0;
	end	
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		for (i = 0, i< 2 ** ADDR_WIDTH-1; i = i+1) begin
			residue_reg[i] = 0;
		end
	end
	else begin
		if (enable) begin
			if (new_line) begin
				
			end
			else begin
			end
		end
	end
end

