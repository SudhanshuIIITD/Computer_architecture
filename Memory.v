`timescale 1ns/1ps
module Memory(in_data_read,funct,mem_data_read);

input [31:0]in_data_read;
input [2:0]funct;
output [31:0]mem_data_read;
/*Instantiating Load Unit*/
Load_Unit LU(.funct(funct),.mem_out(mem_data_read),.mem_in(in_data_read));

endmodule