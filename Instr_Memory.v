`timescale 1ns / 1ps

module Instr_Memory(clk,address,instr);
input clk;
input [11:0]address;
output reg[31:0]instr;
reg [31:0] instr_memory [0:4095]; //Total memory size: 16KB, capable of storing 4096 instructions.

initial $readmemh("Instr_Mem.bin",instr_memory);

always@(posedge clk)
begin
     instr <= instr_memory[address];
end
endmodule