`timescale 1ns / 1ps
module Registers(clk,rst,reg_out_1,reg_out_2,rs1,rs2,rd,reg_wr,reg_din);
input clk,rst;
input [4:0] rs1,rs2,rd;
input [31:0] reg_din;
input reg_wr;
output reg [31:0] reg_out_1,reg_out_2;
reg [31:0] reg_file [31:0];//32 32-bit registers reg_file[0] to reg_file[31]
integer i;

initial
begin
    for(i=0;i<32;i=i+1)
        reg_file[i]=i; //comment out during synthesis 
end

always @(*)
	begin
	       reg_out_1 <= reg_file[rs1];
           reg_out_2 <= reg_file[rs2];
	end
	
always@(negedge clk)
	begin
	   if(reg_wr)
	       reg_file[rd]=reg_din;
	end

endmodule
