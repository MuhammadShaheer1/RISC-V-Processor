module testbench;

reg clk, rst;

wire [31:0] dReadData;
wire [31:0] PC;
wire [31:0] dAddress, dWriteData;
wire MemRead;
wire MemWrite;
wire [31:0] instruction;

top DUT (
clk, rst, instruction, dReadData, PC, dAddress, dWriteData, MemRead, MemWrite);

instruction_memory DUT2 (PC[6:0], instruction, rst);
data_memory DUT3 (dAddress, dWriteData, dReadData, clk, rst, MemRead, MemWrite);

endmodule 
