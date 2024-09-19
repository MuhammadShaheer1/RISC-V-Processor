module register_file (read_addr_1, read_addr_2, write_addr, read_data_1, read_data_2, write_data, reg_write, clk, reset);
input [4:0] read_addr_1, read_addr_2,write_addr;
input [31:0] write_data;
input clk, reset, reg_write;
output read_data_1, read_data_2;

reg [31:0] reg_file [31:0];
integer k;

assign read_data_1 = (read_addr_1 == 0) ? 32'b0 : reg_file[read_addr_1];
assign read_data_2 = (read_addr_2 == 0) ? 32'b0 : reg_file[read_addr_2];

always @ (posedge clk or posedge reset)
begin
	if (reset == 1'b1)
		begin
		for (k = 0; k < 32; k = k + 1)
			begin
			reg_file[k] = 32'b0;
			end
		end
	else if (reg_write == 1'b1)
		reg_file[write_addr] = (write_addr == 0) ? 32'b0 : write_data;
		
end

endmodule 