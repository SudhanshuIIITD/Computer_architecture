`timescale 1ns / 1ps
module Control_Signals(Op,RegWrite,ALUOp,MemRead,MemWrite,MemtoReg,is_Branch,ALUSrc,
select_control_unit);
input [6:0]Op;    
input select_control_unit;
output reg RegWrite;
output reg [1:0] ALUOp;
output reg MemRead;
output reg MemWrite;
output reg MemtoReg;
output reg is_Branch; 
output reg [1:0]ALUSrc;

always @(*)
begin
    if(select_control_unit) begin
        case(Op)
        7'b0110011: //Register format
            begin
            RegWrite<=1;
            ALUOp<=2'b10;
            MemRead<=0;
            MemWrite<=0;
            MemtoReg<=0;
            is_Branch<=0;  
            ALUSrc<=2'b00;
            end
        7'b0000011: //lw
            begin
            RegWrite<=1;
            ALUOp<=2'b00;
            MemRead<=1;
            MemWrite<=0;
            MemtoReg<=1;
            is_Branch<=0;  
            ALUSrc<=2'b01;
            end
         7'b0100011: //sw
            begin
            RegWrite<=0;
            ALUOp<=2'b00;
            MemRead<=0;
            MemWrite<=1;
            MemtoReg<=1'bz;/**/
            is_Branch<=0;  
            ALUSrc<=2'b01;
            end
        7'b0010011: //Immediate
            begin
            RegWrite<=1;
            ALUOp<=2'b11; 
            MemRead<=0;
            MemWrite<=0;
            MemtoReg<=0;
            is_Branch<=0;  
            ALUSrc<=2'b01;
            end 
        7'b1100011: //Branch
            begin
            RegWrite<=0;
            ALUOp<=2'b01;
            MemRead<=0;
            MemWrite<=0;
            MemtoReg<=1'bz;/**/
            is_Branch<=1;  
            ALUSrc<=2'b00;
            end 
         default:
            begin
            RegWrite<=1'b0;
            ALUOp<=2'bzz;
            MemRead<=1'b0;
            MemWrite<=1'b0;
            MemtoReg<=1'bz;
            is_Branch<=1'b0;  
            ALUSrc<=2'bzz;
            end   
        endcase
     end
     else
        begin
            RegWrite<=1'b0;
            ALUOp<=2'bzz;
            MemRead<=1'b0;
            MemWrite<=1'b0;
            MemtoReg<=1'bz;
            is_Branch<=1'b0;  
            ALUSrc<=2'bzz;
        end
end

endmodule
