`timescale 1ns / 1ps
module ALU(ALU_SEL,A,B,ALU_OUT,carry,zero,negative,overflow,underflow);
input [3:0]ALU_SEL;
input [31:0]A,B;
output reg [31:0]ALU_OUT;
output  carry;
output  zero,negative,overflow,underflow;
wire [32:0] tmp;
wire signed [31:0] signed_A; //for sra and srai
assign signed_A = A;
assign tmp = {1'b0,A} + {1'b0,B};
assign carry = tmp[32]; // Carryout flag
assign zero = ~(|ALU_OUT); //zero flag
assign negative = (ALU_OUT[31] == 1 && (ALU_SEL == 4'b0110));
assign overflow = ({carry,ALU_OUT[31]} == 2'b01);
assign underflow = ({carry,ALU_OUT[31]} == 2'b10);
wire [31:0]negate,shift_right,shift_right_alter;
assign negate = 0 - B;
assign shift_right=signed_A>>>B;
assign shift_right_alter=(signed_A>>>(32-(negate[4:0])));
	
always@(*)
    begin
	  case(ALU_SEL)
         0: ALU_OUT<= A & B;
         1: ALU_OUT<= A | B;
         2: ALU_OUT<= A + B;
         4: ALU_OUT<= A ^ B;
         3: ALU_OUT <= B[31]? (((A<<(32-(negate[4:0])))==0 & (negate[4:0]==5'b0))? A : A<<(32-(negate[4:0]))): A<<B; //sll
         9: ALU_OUT <= B[31]? (((A>>(32-(negate[4:0])))==0 & (negate[4:0]==5'b0))? A : A>>(32-(negate[4:0]))):A>>B; //srl
         5: ALU_OUT <= B[31]? (((shift_right_alter==32'hffffffff) & (negate[4:0]==5'b0))? signed_A : shift_right_alter ):shift_right; //sra
         6: ALU_OUT<= A - B;  
         7: ALU_OUT<= A < B ? 32'b1 : 32'b0; //stlu
         8: ALU_OUT<= (A[31] ^ B[31])? {31'b0,A[31]}:{31'b0,(A<B)}; //slt
         10: ALU_OUT<= A<<B[4:0]; //slli
         11: ALU_OUT<= A>>B[4:0]; //srli
         13: ALU_OUT<= signed_A>>>B[4:0]; //srai
         12: ALU_OUT<= -(A|B); //nor
         default: ALU_OUT<=32'bX;
        endcase
    end
endmodule