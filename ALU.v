module ALU (
input [4:0] read_addr,
input [31:0] a,
input [31:0] b,
input [31:0] c,
input [31:0] d,
input [5:0] ALU_Ctrl,
output reg [31:0] result,
output Zero_fg,
output reg PCSrc,
output reg [31:0] dwrite_data,
output reg [31:0] wd);

always @(*)
begin
	case(ALU_Ctrl)
	6'b000000: begin
				  result = {b[19:0], {12{1'b0}}};
				  PCSrc = 0;
				  end
	6'b000001: begin
				  result = {b[19:0], {12{1'b0}}};
				  PCSrc = 1;
				  end
	6'b000010: begin
				  PCSrc = 1;
				  end
	6'b000011: begin
				  result = 0;
				  PCSrc = 1;
				  end 
	6'b000100: begin
				  if (a == b)
				  PCSrc = 1;
				  else
				  PCSrc = 0;
				  end
	6'b000101: begin
				  if (a != b)
				  PCSrc = 1;
				  else
				  PCSrc = 0;
				  end
	6'b000110: begin
				  if ($signed(a) < $signed(b))
				  PCSrc = 1;
				  else
				  PCSrc = 0;
				  end
	6'b000111: begin
				  if ($signed(a) >= $signed(b))
				  PCSrc = 1;
				  else
				  PCSrc = 0;
				  end
	6'b001000: begin
				  if (a < b)
				  PCSrc = 1;
				  else
				  PCSrc = 0;
				  end
	6'b001001: begin
				  if (a >= b)
				  PCSrc = 1;
				  else
				  PCSrc = 0;
				  end
	6'b001010: begin
				  wd = {{24{1'b0}}, d[7:0]};
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b001011: begin
				  wd = {{16{1'b0}}, d[15:0]};
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b001100: begin
				  wd = d;
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b001101: begin
				  wd = {{24{1'b0}}, d[7:0]};
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b001110: begin
				  wd = {{16{1'b0}}, d[15:0]};
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b001111: begin
				  dwrite_data = {{24{1'b0}}, c[7:0]};
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b010000: begin
				  dwrite_data = {{16{1'b0}}, c[15:0]};
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b010001: begin
				  dwrite_data = c;
				  result = b + {{27{1'b0}}, read_addr};
				  PCSrc = 0;
				  end
	6'b010010: begin
				  wd = d;
				  result = a + b;
				  PCSrc = 0;
				  end
	6'b010011: begin
				  wd = d;
				  PCSrc = 0;
				  if ($signed(a) < $signed(b))
				  result = 32'b1;
				  else
				  result = 32'b0;
				  end
	6'b010100: begin
				  wd = d;
				  PCSrc = 0;
				  if (a < b)
				  result = 32'b1;
				  else
				  result = 32'b0;
				  end
	6'b010101: begin
			     wd = d;
				  result = a ^ b;
				  PCSrc = 0;
				  end
	6'b010110: begin
				  wd = d;
				  result = a | b;
				  PCSrc = 0;
				  end
	6'b010111: begin
				  wd = d;
				  result = a & b;
				  PCSrc = 0;
				  end
	6'b011000: begin
				  wd = d;
				  result = a << b;
				  PCSrc = 0;
				  end
	6'b011001: begin
				  wd = d;
				  result = a >> b;
				  PCSrc = 0;
				  end
	6'b011010: begin
				  wd = d;
				  result = a >>> b;
				  PCSrc = 0;
				  end
	6'b011011: begin
				  wd = d;
				  result = a + b;
				  PCSrc = 0;
				  end 
	6'b011100: begin
				  wd = d;
				  result = a - b;
				  PCSrc = 0;
				  end
	6'b011101: begin
				  wd = d;
				  result = a << b;
				  PCSrc = 0;
				  end
	6'b011110: begin
				  wd = d;
				  PCSrc = 0;
				  if ($signed(a) < $signed(b))
				  result = 1;
				  else
				  result = 0;
				  end
	6'b011111: begin
				  wd = d;
				  PCSrc = 0;
				  if (a < b)
				  result = 1;
				  else
				  result = 0;
				  end
	6'b100000: begin
				  wd = d;
				  result = a ^ b;
				  PCSrc = 0;
				  end
	6'b100001: begin
				  wd = d;
				  result = a >> b;
				  PCSrc = 0;
				  end
	6'b100010: begin
				  wd = d;
				  result = a >>> b;
				  PCSrc = 0;
				  end
	6'b100011: begin
				  wd = d;
				  result = a | b;
				  PCSrc = 0;
				  end
	6'b100100: begin
				  wd = d;
				  result = a & b;
				  PCSrc = 0;
				  end
	default : result = 0;
	endcase
end 

assign Zero_fg = (result == 32'b0) ? 1'b1 : 1'b0;

endmodule 