module data_memory (addr, write_data, read_data, clk, reset, mem_read, mem_write);
input [7:0] addr;
input [31:0] write_data;
output [31:0] read_data;
input clk, reset, mem_read, mem_write;
reg [31:0] dmemory [63:0];
integer k;
wire [5:0] shifted_addr;
assign shifted_addr = addr[7:2];
assign read_data = (mem_read) ? dmemory[addr] : 32'bx;

always @(posedge clk or posedge reset)
begin
	if (reset == 1'b1)
	begin
		for (k = 0; k < 64; k = k + 1)
		begin
			dmemory[k] = 32'b0;
		end
		
	end
	else
		if (mem_write) 
		dmemory[addr] = write_data;
end 
endmodule 