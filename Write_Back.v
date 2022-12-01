`timescale 1ns / 1ps

module Write_Back(mem_to_reg,Mem_read_out,ALUresult,out);

input mem_to_reg;
input [31:0]Mem_read_out,ALUresult;
output [31:0]out;

assign out = mem_to_reg ? Mem_read_out : ALUresult;
endmodule