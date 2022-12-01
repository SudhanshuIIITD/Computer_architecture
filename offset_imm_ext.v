`timescale 1ns / 1ps
module offset_imm_ext(clk,instr,IF_ID_Write,offset);
input clk;
input [31:0] instr;
input IF_ID_Write;
output reg [31:0] offset;

always@(negedge clk)
 if(IF_ID_Write)
 begin
    case(instr[6:0]) 
        7'b0100011,7'b0001011: //sw
                begin
                    if(instr[31])
                        offset={20'hfffff,instr[31:25],instr[11:7]};
                    else
                        offset={20'b0,instr[31:25],instr[11:7]};
                end
        7'b0000011: //lw
                begin
                    if(instr[31])
                        offset={20'hfffff,instr[31:20]};
                    else
                        offset={20'b0,instr[31:20]};
                 end
        7'b0010011://addimm
                begin
                    if(instr[31])
                        offset={20'hfffff,instr[31:20]};
                    else
                        offset={20'b0,instr[31:20]};
                 end
        7'b1100011: //branch
                begin
                    if(instr[31])
                        offset={20'hfffff,instr[31],instr[7],instr[30:25],instr[11:8]};
                    else
                        offset={20'b0,instr[31],instr[7],instr[30:25],instr[11:8]};
                end
        default:
                offset=32'hx;
    endcase

 end

endmodule
