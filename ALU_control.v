`timescale 1ns / 1ps
module ALU_control(func_field,ALUOp,ALU_SEL);
input [9:0] func_field; // Instruction[31:25]-(func7) & Instruction[14:12]-(func3)
input [1:0] ALUOp; //comes from the control Unit
output reg [3:0] ALU_SEL; //O/p of the ALU control goes to the ALU to perform the specified operation
always @(*)
    case(ALUOp)
	2'b00: //lw,sw
	   ALU_SEL<=4'b0010;
	2'b01: //branch instn beq
        ALU_SEL<=4'b0110;
    2'b10: //R-type instruction
        case(func_field)
        10'b0000000000: //add 
            ALU_SEL<=4'b0010;
        10'b0100000000: //sub 
            ALU_SEL<=4'b0110;
        10'b0000000111: //AND
            ALU_SEL<=4'b0000;
        10'b0000000110: //OR
            ALU_SEL<=4'b0001;
        10'b0000000010: //slt
            ALU_SEL<=4'b1000;
        10'b0000000011: //sltu
            ALU_SEL<=4'b0111;
        10'b0000000001: //sll
            ALU_SEL<=4'b0011;
        10'b0000000101: //srl
            ALU_SEL<=4'b1001;
        10'b0100000101: //sra
            ALU_SEL<=4'b0101;
        10'b0000000100: //xor
            ALU_SEL<=4'b0100;
        default: ALU_SEL<=4'bz;/**/
        endcase
    2'b11: //I -type instruction
        case(func_field[2:0])
        3'b000: //ADDI
            ALU_SEL<=4'b0010;
        3'b111: //ANDI
            ALU_SEL<=4'b0000;
        3'b110: //ORI
            ALU_SEL<=4'b0001;
        3'b010: //SLTI*
            ALU_SEL<=4'b1000;
        3'b011: //SLTIU*
            ALU_SEL<=4'b0111;
        3'b100: //XORI
            ALU_SEL<=4'b0100;
        3'b001: //SLLI
            ALU_SEL<=4'b1010;
        3'b101:
            if(func_field[8])
                ALU_SEL<=4'b1101; //SRAI
            else 
                ALU_SEL<=4'b1011; //SRLI
        default:
            ALU_SEL<=4'bz;
        endcase   
        default: ALU_SEL<=4'bz;                           
    endcase      
endmodule
