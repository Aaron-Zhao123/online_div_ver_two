module w_frac_logic(
clk,
enable,
asyn_reset,
d_plus_vec,
d_minus_vec,
v_plus_frac,
v_minus_frac,
w_plus_frac,
w_minus_frac,
rd_addr,
wr_addr,
q_value
);

parameter UNROLLING = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH = 7;
parameter UPPER_WIDTH = 6;

input clk;
input enable;
input asyn_reset;
input [unrolling-1:0] d_plus_vec, d_minus_vec;
input [unrolling-1:0] v_plus_frac, v_minus_frac;
input [ADDR_WIDTH-1:0] rd_addr, wr_addr;

output [unrolling-1:0] w_plus_frac, w_minus_frac;

reg [UNROLLING-1 :0] residue_plus_reg [2**ADDR_WIDTH-1 :0];
reg [UNROLLING-1 :0] residue_minus_reg [2**ADDR_WIDTH-1 :0];

initial begin
	residue_plus_reg[0:UNROLLING-1][0:2**ADDR_WIDTH-1]= 0;
	residue_minus_reg[0:UNROLLING-1][0:2**ADDR_WIDTH-1]= 0;
end

always @ (posedge clk or posedge asyn_reset)
	if (asyn_reset) begin
		residue_plus_reg[0:UNROLLING-1][0:2**ADDR_WIDTH-1]= 0;
		residue_minus_reg[0:UNROLLING-1][0:2**ADDR_WIDTH-1]= 0;

	end
	else begin
		if (enable) begin
			residue_plus_reg[wr_addr] =   
			residue_minus_reg[wr_addr] = 
			residue_plus_reg [rd_addr];
			residue_minus_reg[rd_addr];
		end
	end
end

endmodule
