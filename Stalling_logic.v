`timescale 1ns / 1ps

module Stalling_logic(ID_EX_MEMRead,Rd_EX,Ra,Rb,PCWrite,IF_ID_Write,select_control_unit);
input ID_EX_MEMRead;
input [4:0]Rd_EX,Ra,Rb;
output reg PCWrite,IF_ID_Write,select_control_unit;

always@* 
    if((ID_EX_MEMRead & ((Rd_EX==Ra) || (Rd_EX==Rb))) )
        begin
            PCWrite<=0;          //stalls fetch, decode and control unit 
            IF_ID_Write<=0;
            select_control_unit<=0;
        end
    else 
        begin
            PCWrite<=1;
            IF_ID_Write<=1;
            select_control_unit<=1;
        end
endmodule

