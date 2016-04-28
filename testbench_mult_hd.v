`timescale 1ns/1ps
module testbench_mult_hd();

reg clk;
reg asyn_reset;
reg [1:0] x_value, y_value;
integer stop;
integer flag;
wire [1:0] p_value; 

reg data_x_vld,data_y_vld,data_out_rdy;
wire data_x_rdy,data_y_rdy,data_out_vld;

integer data_in_file_x,data_in_file_y,data_out_file;
integer scan_file_x,scan_file_y;
integer cnt = 0;

Multiplier_hd test(x_value, y_value, p_value, clk, asyn_reset,
 data_x_vld, data_x_rdy, data_y_vld, data_y_rdy, data_out_vld, data_out_rdy);

initial begin
	clk=1;
	while(1) begin
		#10 clk=~clk;
	end
end




initial begin
  data_in_file_x=$fopen("/home/aaron/verilog/mult_hd/Online_mult_hd/x_value.txt","r");
  
  data_in_file_y=$fopen("/home/aaron/verilog/mult_hd/Online_mult_hd/y_value.txt","r");
  
  
  data_out_file=$fopen("/home/aaron/verilog/mult_hd/Online_mult_hd/product.dat","w");
  
end

initial begin
	scan_file_x=$fscanf(data_in_file_x,"%b",x_value);
	scan_file_y=$fscanf(data_in_file_y,"%b",y_value);
	data_x_vld <= 1;
	data_y_vld <= 1;
	data_out_rdy <= 1;
	asyn_reset <= 1;
	flag <= 0;
	stop <= 3;

end

always@(negedge clk) begin

	if(data_x_rdy && data_x_vld) begin
		scan_file_x=$fscanf(data_in_file_x,"%b",x_value);
	end
	if (data_y_rdy && data_y_vld) begin
		scan_file_y=$fscanf(data_in_file_y,"%b",y_value);
	end
	if (data_out_rdy && data_out_vld) begin
		$fwrite(data_out_file,"%b\n",p_value);
		cnt = cnt + 1;
	end
	if (cnt == 20) begin
		asyn_reset = 1;
		flag <= 1;
	end
	if (flag == 1) begin
		stop <= stop -1;
		if (stop  == 0) begin
			flag <= 0;
			stop <= 3;
			asyn_reset <= 0;
			cnt <= 0;
		end
	end

	else begin
		asyn_reset = 0;
	end
end

endmodule

