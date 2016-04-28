module generate_CA_reg_hd(comp_cycle,rd_addr,x_value,y_value,x_plus,x_minus,y_plus,y_minus,clk,master_cnt,enable_all,wr_enable,asyn_reset);

parameter Num_bits=4; //unrolling this many bits
parameter RAM_ADDR_WIDTH=7;

input wr_enable; 
input enable_all;
input asyn_reset;
input clk;
input[RAM_ADDR_WIDTH+2-1:0] master_cnt;
input [RAM_ADDR_WIDTH-1:0] comp_cycle,rd_addr;
input[1:0] x_value, y_value;


output [Num_bits-1 : 0] x_plus,x_minus,y_plus,y_minus;


wire[3:0] tmp_write;
wire[Num_bits*2-1:0] tmp_read_data_x,tmp_read_data_y;
wire[1:0] sel;
wire [RAM_ADDR_WIDTH-1:0] wr_addr;
reg we_one, we_two, we_three, we_four;


assign tmp_write = {x_value,y_value};
assign sel=master_cnt[1:0];

assign wr_addr = master_cnt[RAM_ADDR_WIDTH+2-1:2];



single_clk_ram_4bit ram1(tmp_write,wr_addr,rd_addr,we_one,asyn_reset,clk,{tmp_read_data_x[7:6],tmp_read_data_y[7:6]}); //read and write to ram at the same time
single_clk_ram_4bit ram2(tmp_write,wr_addr,rd_addr,we_two,asyn_reset,clk,{tmp_read_data_x[5:4],tmp_read_data_y[5:4]});
single_clk_ram_4bit ram3(tmp_write,wr_addr,rd_addr,we_three,asyn_reset,clk,{tmp_read_data_x[3:2],tmp_read_data_y[3:2]});
single_clk_ram_4bit ram4(tmp_write,wr_addr,rd_addr,we_four,asyn_reset,clk,{tmp_read_data_x[1:0],tmp_read_data_y[1:0]});

always @ (*) begin
	if (enable_all == 1 && wr_enable == 1 ) begin
		case (sel)
			2'b00:begin
				we_one<=1'b1;
				we_two<=1'b0;
				we_three<=1'b0;
				we_four<=1'b0;
			end
			2'b01:begin
				we_one<=1'b0;
				we_two<=1'b1;
				we_three<=1'b0;
				we_four<=1'b0;
			end
			2'b10:begin
				we_one<=1'b0;
				we_two<=1'b0;
				we_three<=1'b1;
				we_four<=1'b0;
			end
			2'b11:begin
				we_one<=1'b0;
				we_two<=1'b0;
				we_three<=1'b0;
				we_four<=1'b1;
			end
			default:begin
				we_one<=1'b0;
				we_two<=1'b0;
				we_three<=1'b0;
				we_four<=1'b0;
			end
		endcase
	end
	else begin
		we_one<=1'b0;
		we_two<=1'b0;
		we_three<=1'b0;
		we_four<=1'b0;
	end

end



assign 		x_plus[3]=tmp_read_data_x[7];
assign		x_minus[3]=tmp_read_data_x[6];
assign 		y_plus[3]=tmp_read_data_y[7];
assign		y_minus[3]=tmp_read_data_y[6];

assign		x_plus[2]=tmp_read_data_x[5];
assign		x_minus[2]=tmp_read_data_x[4];
assign 		y_plus[2]=tmp_read_data_y[5];
assign		y_minus[2]=tmp_read_data_y[4];

assign		x_plus[1]=tmp_read_data_x[3];
assign		x_minus[1]=tmp_read_data_x[2];
assign		y_plus[1]=tmp_read_data_y[3];
assign		y_minus[1]=tmp_read_data_y[2];

assign		x_plus[0]=tmp_read_data_x[1];
assign		x_minus[0]=tmp_read_data_x[0];
assign		y_plus[0]=tmp_read_data_y[1];
assign		y_minus[0]=tmp_read_data_y[0];
endmodule
