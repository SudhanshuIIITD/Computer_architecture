`timescale 1ns/1ps

module Instruction_Decode(clk,rst,reg_write_data,reg_write_addr,
reg_wr,reg_read_data1,reg_read_data2,instr_OP,instr,IF_ID_Write,
Ra,Rb,offset);

input clk,rst;                
input [31:0]reg_write_data;
input reg_wr;
input [6:0] instr_OP;
input [31:0] instr;
input IF_ID_Write;
input [4:0]reg_write_addr;
input [4:0]Ra;
input [4:0]Rb;
output [31:0]reg_read_data1;
output [31:0]reg_read_data2;
output [31:0]offset;

/*module instantiations of register file and offset extension*/
Registers Registers(.clk(clk),.reg_out_1(reg_read_data1),.reg_out_2(reg_read_data2),.rs1(Ra),.rs2(Rb),.rd(reg_write_addr),.reg_wr(reg_wr),.reg_din(reg_write_data));
offset_imm_ext offset_imm_ext(.clk(clk),.instr(instr),.IF_ID_Write(IF_ID_Write),.offset(offset));

endmodule