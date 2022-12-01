`timescale 1ns / 1ps

module Execute(clk,A,B,offset,funct3,funct7,is_Branch,
ALUOp,ALUSrc,Result,Branch_taken,pc,target_pc,mem_data_write);
input clk,is_Branch;
input [31:0]A,B;
input [2:0]funct3;
input [6:0]funct7;
input [1:0]ALUOp,ALUSrc;
input [31:0]offset,pc;

output [31:0]Result;
output [31:0]target_pc; 
output reg Branch_taken;
output reg [31:0]mem_data_write;

wire [3:0]ALU_SEL;
reg [31:0]operand1,operand2;
wire [31:0]inp_A,inp_B;
wire zero;

/*ALU Unit and ALU-Control-Unit*/
ALU_control ALU_control(.func_field({funct7,funct3}),.ALUOp(ALUOp),.ALU_SEL(ALU_SEL)); 
ALU ALU(.ALU_SEL(ALU_SEL),.A(inp_A),.B(inp_B),.ALU_OUT(Result),.carry(),.zero(zero),.negative(),.overflow(),.underflow());

assign inp_A = operand1;
assign inp_B = operand2;

always@(*)
begin
    case(ALUSrc)
        2'b00: //R-type or SB-type
            begin
                operand1=A;
                operand2=B;
            end 
        2'b01: //I-type(incl lw) or S-type 
            begin
                operand1=A;
                operand2=offset;
            end 
        default: begin 
                    operand1=A;    
                    operand2=B;
                 end
      endcase
end

always @(*) 
    begin
        if(ALUOp==2'b00)
        mem_data_write <= B;//for store Instr, B is the store value
    end

//branch target address calculation if branch is taken
assign target_pc = (Branch_taken)?(pc + (offset<<1)):32'b0;

//Is branch taken?
always @(*) 
    begin
        if(ALUSrc==2'b10)
            Branch_taken=is_Branch;
        else
        case (funct3)
            3'b000: Branch_taken = is_Branch & zero;//beq
            default: Branch_taken = 1'b0;
        endcase
    end
endmodule