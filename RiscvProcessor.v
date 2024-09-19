module RiscvProcessor # (parameter [31:0] INITIAL_PC = 32'h00400000)
(
input clk, rst,
input [31:0] instruction,
input [31:0] dReadData,
output [31:0] PC,
output [31:0] dAddress, dWriteData,
output MemRead,
output MemWrite

);

wire Zero;
wire PcSrc, ALUSrc, RegWrite, MemtoReg;
wire [3:0] ALUCtrl;

control U1(instruction[6:0], MemRead, MemtoReg, ALUop, MemWrite, ALUSrc, RegWrite);

alucontrol U2(ALUop, {instruction[30], instruction[14:12]}, ALUCtrl);

wire [4:0] read_addr_1, read_addr_2, write_addr;
wire [31:0] read_data_1, read_data_2, write_data;

assign read_addr_1 = instruction[19:15];
assign read_addr_2 = instruction[24:20];
assign write_addr = instruction[11:7];

register_file U4(
.read_addr_1(read_addr_1),
.read_addr_2(read_addr_2),
.write_addr(write_addr),
.read_data_1(read_data_1),
.read_data_2(read_data_2),
.write_data(write_addr),
.reg_write(RegWrite),
.clk(clk),
.reset(rst)
);


reg [31:0] imm_ext;
always @(*)
begin
case(ALUop)
3'b0000:	imm_ext = {{12{instruction[31]}}, instruction[31:12]};
3'b0001:	imm_ext = {{12{instruction[31]}}, instruction[31:12]};
3'b0010:	imm_ext = {{12{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
3'b0011:	imm_ext = {{20{instruction[31]}}, instruction[31:20]};
3'b0100:	imm_ext = {{20{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
3'b0101:	imm_ext = {{20{instruction[31]}}, instruction[31:20]};
3'b0110:	imm_ext = {{20{instruction[31]}}, instruction[31:25], instruction[7:11]};
3'b0111:	imm_ext = {{20{instruction[31]}}, instruction[31:20]};
3'b1000:	imm_ext = 32'b0;
default: imm_ext = 32'b0;
endcase
end

wire [31:0] operand2, ALU_out;
assign operand2 = (ALUSrc == 1'b1) ? imm_ext : read_data_2;

ALU alu_unit(
.read_addr(read_addr_1),
.a(read_data_1),
.b(operand2),
.c(read_data_2),
.d(dReadData),
.ALU_Ctrl(ALUCtrl),
.result(ALU_out),
.Zero_fg(Zero),
.PCSrc(PcSrc),
.dwrite_data(dwrite_data),
.wd(wd)
);

wire [31:0] pc2, pc_b, pc_next;
reg [31:0] pc_current;

always @ (posedge clk or negedge rst)
begin
if (rst == 0)
	pc_current <= INITIAL_PC;
else
	begin
	pc_current <= pc_next;
	end
end 

assign pc2 = pc_current + 4;
assign pc_b = pc_current + {imm_ext[30:0], 1'b0};
assign pc_next = (PcSrc) ? pc2 : pc_b;

assign write_data = (MemtoReg == 1'b1) ? wd : ALU_out;

assign dAddress = ALU_out;
assign dWriteData = dwrite_data;
assign PC = pc_current;

endmodule

module control (opcode, mem_read, mem_to_reg, aluop, mem_write, alusrc, reg_write);
input [6:0] opcode;
output mem_read, mem_to_reg, mem_write, alusrc, reg_write;
output reg [3:0] aluop;

assign mem_read=(opcode[5])&(~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]);//100011
assign mem_to_reg=(opcode[5])&(~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]);//100011
assign mem_write=(opcode[5])&(~opcode[4])&(opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]);//101011
assign alusrc=((~opcode[5])&(~opcode[4])&(opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0])) | ((~opcode[5])&(~opcode[4])&(opcode[3])&(opcode[2])&(~opcode[1])&(~opcode[0])) | ((opcode[5])&(~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0])) | (((opcode[5])&(~opcode[4])&(opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]))); //001000,001100,100011,101011
assign reg_write=(~opcode[5])&(~opcode[4])&(~opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0]) | ((~opcode[5])&(~opcode[4])&(opcode[3])&(~opcode[2])&(~opcode[1])&(~opcode[0])) | ((~opcode[5])&(~opcode[4])&(opcode[3])&(opcode[2])&(~opcode[1])&(~opcode[0])) | ((opcode[5])&(~opcode[4])&(~opcode[3])&(~opcode[2])&(opcode[1])&(opcode[0]));//000000,001000,001100,100011
always @(opcode)
begin
case(opcode)
7'b0110111: aluop = 4'b0000;
7'b0010111: aluop = 4'b0001;
7'b1101111: aluop = 4'b0010;
7'b1100111: aluop = 4'b0011;
7'b1100011: aluop = 4'b0100;
7'b0000011: aluop = 4'b0101;
7'b0100011: aluop = 4'b0110;
7'b0010011: aluop = 4'b0111;
7'b0110011: aluop = 4'b1000;
endcase 
end
endmodule

module alucontrol (aluop, funct, out_to_alu);
input [3:0] aluop;
input [3:0] funct;
output reg [5:0] out_to_alu;

always @ (*)
begin
case(aluop)
4'b0000:	out_to_alu = 6'b000000;
4'b0001:	out_to_alu = 6'b000001;
4'b0010:	out_to_alu = 6'b000010;
4'b0011:	out_to_alu = 6'b000011;
4'b0100:	begin
			case(funct[2:0])
			3'b000:	out_to_alu = 6'b000100;
			3'b001:	out_to_alu = 6'b000101;
			3'b100:	out_to_alu = 6'b000110;
			3'b101:	out_to_alu = 6'b000111;
			3'b110:	out_to_alu = 6'b001000;
			3'b111:	out_to_alu = 6'b001001;
			endcase
			end
4'b0101:	begin
			case(funct[2:0])
			3'b000:	out_to_alu = 6'b001010;
			3'b001:	out_to_alu = 6'b001011;
			3'b010:	out_to_alu = 6'b001100;
			3'b100:	out_to_alu = 6'b001101;
			3'b101:	out_to_alu = 6'b001110;
			endcase
			end
4'b0110:	begin
			case(funct[2:0])
			3'b000:	out_to_alu = 6'b001111;
			3'b001:	out_to_alu = 6'b010000;
			3'b010:	out_to_alu = 6'b010001;
			endcase
			end
4'b0111:	begin
			case(funct)
			4'bx000: out_to_alu = 6'b010010;
			4'bx010:	out_to_alu = 6'b010011;
			4'bx011:	out_to_alu = 6'b010100;
			4'bx100:	out_to_alu = 6'b010101;
			4'bx110:	out_to_alu = 6'b010110;
			4'bx111:	out_to_alu = 6'b010111;
			4'b0001:	out_to_alu = 6'b011000;
			4'b0101:	out_to_alu = 6'b011001;
			4'b1101:	out_to_alu = 6'b011010;
			endcase
			end
4'b1000:	begin
			case(funct)
			4'b0000:	out_to_alu = 6'b011011;
			4'b1000:	out_to_alu = 6'b011100;
			4'b0001:	out_to_alu = 6'b011101;
			4'b0010:	out_to_alu = 6'b011110;
			4'b0011:	out_to_alu = 6'b011111;
			4'b0100:	out_to_alu = 6'b100000;
			4'b0101:	out_to_alu = 6'b100001;
			4'b1101:	out_to_alu = 6'b100010;
			4'b0110:	out_to_alu = 6'b100011;
			4'b0111:	out_to_alu = 6'b100100;
			endcase
			end
endcase
end

endmodule 