`timescale 1ns/1ps

module Load_Unit(funct,mem_out,mem_in);
input [31:0] mem_in;
input[2:0] funct;
output reg [31:0] mem_out;

always@(*)
case(funct)
    3'b010://load word
        mem_out=mem_in;
    default:
        mem_out=32'b0;
    endcase

endmodule