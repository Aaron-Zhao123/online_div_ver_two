module generate_CA_reg_v2 (
enable,
refresh,
asyn_reset,
clk,
x_in,
y_in,
x_plus_delay,
x_minus_delay,
y_plus_rd,
y_minus_rd,
accum,
counter,
shift_cnt
);
parameter unrolling  = 64;
parameter online_delay = 3;
parameter ADDR_WIDTH=7;

input enable;
input asyn_reset;
input clk;
input [1:0] x_in, y_in;
input [(ADDR_WIDTH -1):0] accum;
input [10:0] counter;
input refresh;
input [10:0] shift_cnt;

output [unrolling -1 :0] x_plus_delay, x_minus_delay, y_plus_rd, y_minus_rd;

wire [unrolling-1:0] x_plus_rd, x_minus_rd;
reg [unrolling -1 :0] x_plus_wr, x_minus_wr, y_plus_wr, y_minus_wr;
reg [unrolling -1 :0] x_plus_wr_rev, x_minus_wr_rev, y_plus_wr_rev, y_minus_wr_rev;
reg [1:0] x_value, y_value;

wire wr_enable;
wire [(ADDR_WIDTH-1):0] addr;
//wire[10:0] shift_cnt;


//assign shift_cnt = 64 - counter -1;
assign addr = accum;
assign wr_enable = enable;

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		x_value <= 0;
		y_value <= 0;
	end
	else begin
		if (enable) begin
			x_value <= x_in;
			y_value <= y_in;
		end
	end
end

initial begin
	x_plus_wr <= 0;
	x_minus_wr <= 0;
	y_plus_wr <= 0;
	y_minus_wr <= 0;
	x_plus_wr_rev <= 0;
	x_minus_wr_rev <= 0;
	y_plus_wr_rev <= 0;
	y_minus_wr_rev <= 0;
end

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset) begin
		x_plus_wr <= 0;
		x_minus_wr <= 0;
		y_plus_wr <= 0;
		y_minus_wr <= 0;
	end
	else begin
		if (enable) begin
			if (refresh) begin
				x_plus_wr[unrolling-2:0] <= 0;
				x_minus_wr[unrolling-2:0] <= 0;
				y_plus_wr[unrolling-2:0]<= 0;
				y_minus_wr[unrolling-2:0]<= 0;
				x_plus_wr[unrolling -1] <= x_value[1];
				x_minus_wr[unrolling -1] <= x_value[0];
				y_plus_wr[unrolling -1]<= y_value[1];
				y_minus_wr[unrolling -1]<= y_value[0];
			end
			else begin
				x_plus_wr <= {x_plus_wr[unrolling - 2:0],x_value[1]};
				x_minus_wr <= {x_minus_wr[unrolling - 2:0],x_value[0]};
				y_plus_wr <= {y_plus_wr[unrolling - 2:0],y_value[1]};
		        	y_minus_wr <= {y_minus_wr[unrolling - 2:0],y_value [0]};
				x_plus_wr_rev <= x_plus_wr << shift_cnt;
				x_minus_wr_rev <= x_minus_wr << shift_cnt;
				y_plus_wr_rev <= y_plus_wr << shift_cnt;
				y_minus_wr_rev <= y_minus_wr << shift_cnt;
			end	
		end
	end
end

single_clk_ram_64bits ram1(
	x_plus_wr_rev,
	addr,
	addr,
	wr_enable,
	asyn_reset,
	clk,
	x_plus_rd
);

D_FF D_x_plus(
x_plus_rd,
x_plus_delay,
clk,
enable,
asyn_reset
);
defparam D_x_plus.delay = 1;
defparam D_x_plus.width = unrolling;


single_clk_ram_64bits ram2(
	x_minus_wr_rev,
	addr,
	addr,
	wr_enable,
	asyn_reset,
	clk,
	x_minus_rd
);

D_FF D_x_minus(
x_minus_rd,
x_minus_delay,
clk,
enable,
asyn_reset
);
defparam D_x_minus.delay = 1;
defparam D_x_minus.width = unrolling;


single_clk_ram_64bits ram3(
	y_plus_wr_rev,
	addr,
	addr,
	wr_enable,
	asyn_reset,
	clk,
	y_plus_rd
);

single_clk_ram_64bits ram4(
	y_minus_wr_rev,
	addr,
	addr,
	wr_enable,
	asyn_reset,
	clk,
	y_minus_rd
);
endmodule
