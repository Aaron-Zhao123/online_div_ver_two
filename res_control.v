module res_control(
clk,
x_plus,
x_minus,
y_plus,
y_minus,
z_plus_shifted,
z_minus_shifted,
comp_cycle,
read_addr,
write_addr,
carry_out_control,
cout_to_Vreg_one,
cout_to_Vreg_two,
shift_to_upper_bits,
borrow_in_upper, 
enable, 
enable_shift,
enable_V_reg,
asyn_reset);

parameter bits=4;
parameter RAM_ADDR_WIDTH=7;

input clk;
input enable;
input asyn_reset;
input enable_shift;
input enable_V_reg;
input [1:0] carry_out_control;
input [bits-1:0] x_plus,x_minus,y_plus,y_minus;
input[RAM_ADDR_WIDTH - 1:0] comp_cycle,read_addr,write_addr;
output [bits-1:0] z_plus_shifted,z_minus_shifted;
output [1:0] cout_to_Vreg_one, cout_to_Vreg_two;
output [1:0] shift_to_upper_bits;
output borrow_in_upper;
genvar i;

wire[bits-1:0] z_plus,z_minus,residue_plus,residue_minus;
wire [1:0] cout_one,cout_two;
reg [1:0] cin_one,cin_two;
reg [bits-1:0] z_plus_shifted,z_minus_shifted;
reg [1:0] shift_in,shift_out;
reg [1:0] shift_to_upper_bits;
reg [1:0] cout_to_Vreg_one, cout_to_Vreg_two;
reg we;
reg borrow_in,borrow_in_upper,borrow_out;

four_bits_parallel_adder adder(x_plus,x_minus,y_plus,y_minus,residue_plus,residue_minus,z_plus,z_minus,cin_one,cin_two,cout_one,cout_two);

// cin to the adder, cout from the adder
// carry control logic

always @ (posedge clk or posedge asyn_reset) begin
	if (asyn_reset == 1) begin
		cin_one <= 0;
		cin_two <= 0;
		borrow_out <= 0;
	end
	else begin
		if (enable) begin 
			if (carry_out_control == 1) begin
			 // loop back to the adder
				cin_one <= cout_one;
				cin_two <= cout_two;
				borrow_out <= borrow_in;
			end
		end
		if (carry_out_control == 0) begin
			cin_one <= 0;
			cin_two <= 0;
			
		end
	end
end

always @ (*) begin
	if (carry_out_control == 2) begin
		cout_to_Vreg_one <= cout_one;
		cout_to_Vreg_two <= cout_two;
	end
	else begin
		cout_to_Vreg_one <= 0;
		cout_to_Vreg_two <= 0;
	end
end

// shifting mechanism
always @ (*) begin
	z_plus_shifted <= {z_plus[(bits-2):0],shift_in[1]};
	z_minus_shifted <= {z_minus[(bits-2):0],shift_in[0]};
end

always @ (*) begin
	if (asyn_reset == 1) begin
		shift_out <= 0;
		shift_to_upper_bits <= 0;
		borrow_in <= 0;
		borrow_in_upper <= 0;
	end
	else begin
		if (enable_shift == 1) begin 
			shift_out[1] <= z_plus [3];
			shift_out[0] <= z_minus [3];
		end
		else begin
			shift_out <= 0;
		end
		if ((z_plus - borrow_out)< z_minus) begin
			borrow_in <= 1;
		end
		else begin
			borrow_in <= 0;
		end
		if (enable_V_reg == 1) begin
			shift_to_upper_bits[1] <= z_plus[3];
			shift_to_upper_bits[0] <= z_minus[3];
			borrow_in_upper <= borrow_in;
		end	
		else begin
			shift_to_upper_bits <= 0;
			borrow_in_upper <= 0;
		end
	end
end

always @ (posedge clk) begin
	if (enable_shift == 1) begin
		shift_in <= shift_out;
	end
	else begin
		shift_in <= 0;
	end

end


//RAM block for residue, stroing shifted z values and feed back as res value

//assign write_addr = comp_cycle;
//assign read_addr = comp_cycle;


single_clk_ram_4bit ram1(z_plus_shifted,write_addr,read_addr,we,asyn_reset,clk,residue_plus );
single_clk_ram_4bit ram2(z_minus_shifted,write_addr,read_addr,we,asyn_reset,clk,residue_minus );

always @ (*) begin
	if (carry_out_control == 2 || carry_out_control == 1) begin
		we <= 1;
	end
	else begin
		we <= 0;
	end
end



endmodule
