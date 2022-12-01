`timescale 1ns/1ps
module Instruction_Fetch #(parameter BOOT_ADDRESS=32'b0)
(clk,rst,instr,pc,target_pc,Branch_taken,PCWrite,Ra,Rb,Rd,
is_invalid_instr);
input clk,rst,Branch_taken,PCWrite;
input [31:0]target_pc;
input [31:0]instr;
output reg [31:0]pc;
output reg[4:0]Ra,Rb,Rd; 
output reg is_invalid_instr;

/*PC*/
always@(posedge clk)
begin
    if(rst)
        pc <= BOOT_ADDRESS;
    else 
         begin 
            if(Branch_taken)
                pc <= target_pc;
            else if(PCWrite)
                pc <= pc+4;
        end
end

/*Decoding Instruction format*/
always@(*)                          
    begin
        case(instr[6:0])
            7'b0110011: //Register format
                begin
                    is_invalid_instr<=1'b0;
                    Ra<=instr[19:15];
                    Rb<=instr[24:20];
                    Rd<=instr[11:7];
                end
             7'b0010011: //I-format
                begin
                    is_invalid_instr<=1'b0;
                    Ra<=instr[19:15];
                    Rb<=5'b0000z;/**/
                    Rd<=instr[11:7];
                end
             7'b0000011: //load type
                begin
                    is_invalid_instr<=1'b0;
                    Ra<=instr[19:15];
                    Rb<=5'b0000z;/**/
                    Rd<=instr[11:7];
                end
             7'b0100011: //Store type
                begin
                    is_invalid_instr<=1'b0;
                    Ra<=instr[19:15];
                    Rb<=instr[24:20];
                    Rd<=5'b0000z;/**/
                end        
             7'b1100011: //Branch type
                begin
                    is_invalid_instr<=1'b0;
                    Ra<=instr[19:15];
                    Rb<=instr[24:20];
                    Rd<=5'b0000z;/**/
                end
             default:
                begin
                    is_invalid_instr<=1'b1;
                    Ra<=5'b0000z;/**/
                    Rb<=5'b0000z;/**/
                    Rd<=5'b0000z;/**/
                end
        endcase
    end

endmodule

