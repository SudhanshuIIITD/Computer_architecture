`timescale 1ns / 1ps

module top_module#(parameter BOOT_ADDRESS=32'b0)
(clk,rst,Instr_in,pc,Ra,Rb,Rd,instr_addr,Ra_data,Rb_data,offset,Branch_taken,target_pc,ALU_Output,MA_ALUResult,data_out,address_out,
mem_read_ctrl,mem_write_ctrl,data_in,temp);
input clk,rst;
input [31:0]Instr_in;
input [31:0]data_in;
output wire mem_read_ctrl,mem_write_ctrl;
output wire [31:0]ALU_Output,data_out;
output wire [31:0]address_out;
output wire [11:0]instr_addr;
output reg [31:0]pc;
output reg [31:0]Ra_data,Rb_data,offset;
output reg [31:0]MA_ALUResult;
output wire Branch_taken;
output wire [31:0]target_pc;
output reg [4:0] Ra,Rb,Rd;
output wire [31:0]temp;

/*wires as interface between different stages*/
wire [31:0]IF_ID_wire_0;            //instruction
assign IF_ID_wire_0=Instr_in;  
wire [31:0]IF_ID_wire_1;            //pc  
wire [4:0]IF_ID_register_wire_0;    //Ra register
wire [4:0]IF_ID_register_wire_1;    //Rb register
wire [4:0]IF_ID_register_wire_2;    //Rd register  
wire [31:0]ID_EX_wire_1;            //Data in Ra 
wire [31:0]ID_EX_wire_2;            //Data in Rb
wire [31:0]ID_EX_wire_3;            //offset/immediate             
wire [31:0]EX_MEM_wire_0;           //ALUResult
wire [31:0]EX_MEM_wire_1;           //store data 
wire [31:0]MEM_WB_wire;             //data read from memory for load
wire [4:0]ID_EX_register_wire[2:0]; //register wires between ID and EX(index0=Ra ,1=Rb ,2=Rd)
wire PCWrite,IF_ID_Write,select_control_unit,is_invalid_instr;  //control signals used for stalling

/*control signals from control unit*/
wire ID_EX_ctrl_wire[0:8]; //index0=ALU_src[0], index1 and 2=ALUOp, index3=mem_write, index4=mem_Read, index5=mem_to_reg, index6=Reg_write, index7=ALUSrc[1] ,index8=Branch 
reg ID_EX_ctrl[0:8];       //index0=ALU_src[0], index1 and 2=ALUOp, index3=mem_write, index4=mem_Read, index5=mem_to_reg, index6=Reg_write, index7=ALUSrc[1] ,index8=Branch

/*pipeline registers to store data between different registers*/
reg [31:0] Instr,Instr_EX,pc_EX;    //Instr and pc values at EX stage        
reg [2:0]EX_MEM_funct3;             //function3                  
reg [31:0]MEM_WB[0:1];              //index0=ALUresult ,index1=MEM_read_data
reg EX_MEM_ctrl[0:1];               //index0=mem_to_reg, index1=Reg_write
reg MEM_WB_ctrl[0:1];               //index0=mem_to_reg, index1=Reg_write
reg [4:0]Ra_EX,Rb_EX,Rd_EX;                      
reg [4:0]EX_MEM_register;           //pipelined register Rd
reg [4:0]MEM_WB_register;           //pipelined register Rd

/*Instantiating pipeline stages*/
Instruction_Fetch #(.BOOT_ADDRESS(BOOT_ADDRESS))IF(.clk(clk),.rst(rst),.instr(IF_ID_wire_0),.pc(IF_ID_wire_1),.target_pc(target_pc),.Branch_taken(Branch_taken),.PCWrite(PCWrite),.Ra(IF_ID_register_wire_0),.Rb(IF_ID_register_wire_1),.Rd(IF_ID_register_wire_2),.is_invalid_instr(is_invalid_instr));
Control_Signals CS(.Op(Instr[6:0]),.RegWrite(ID_EX_ctrl_wire[6]),.ALUOp({ID_EX_ctrl_wire[1],ID_EX_ctrl_wire[2]}),.MemRead(ID_EX_ctrl_wire[4]),.MemWrite(ID_EX_ctrl_wire[3]),.MemtoReg(ID_EX_ctrl_wire[5]),.is_Branch(ID_EX_ctrl_wire[8]),.ALUSrc({ID_EX_ctrl_wire[0],ID_EX_ctrl_wire[7]}),.select_control_unit(select_control_unit));
Instruction_Decode ID(.clk(clk),.rst(rst),.reg_write_data(temp),.reg_wr(MEM_WB_ctrl[1]),.reg_write_addr(MEM_WB_register),.reg_read_data1(ID_EX_wire_1),.reg_read_data2(ID_EX_wire_2),.instr(IF_ID_wire_0),.instr_OP(Instr[6:0]),.Ra(IF_ID_register_wire_0),.Rb(IF_ID_register_wire_1),.offset(ID_EX_wire_3),.IF_ID_Write(IF_ID_Write));
Stalling_logic SL(.ID_EX_MEMRead(ID_EX_ctrl_wire[4]),.Rd_EX(Rd_EX),.Ra(Ra),.Rb(Rb),.PCWrite(PCWrite),.IF_ID_Write(IF_ID_Write),.select_control_unit(select_control_unit));
Execute EX(.clk(clk),.A(Ra_data),.B(Rb_data),.offset(offset),.funct3(Instr_EX[14:12]),.funct7(Instr_EX[31:25]),.is_Branch(ID_EX_ctrl[8]),.ALUOp({ID_EX_ctrl[1],ID_EX_ctrl[2]}),.ALUSrc({ID_EX_ctrl_wire[0],ID_EX_ctrl_wire[7]}),.Result(EX_MEM_wire_0),.Branch_taken(Branch_taken),.pc(pc_EX),.target_pc(target_pc),.mem_data_write(EX_MEM_wire_1));                                                                                                                                                                                                                                                            
Memory MA(.in_data_read(data_in),.funct(EX_MEM_funct3),.mem_data_read(MEM_WB_wire));
Write_Back Write_Back(.mem_to_reg(MEM_WB_ctrl[0]),.Mem_read_out(MEM_WB[1]),.ALUresult(MEM_WB[0]),.out(temp));

/*outputs from pipeline registers*/
assign data_out=(ID_EX_ctrl_wire[3])?EX_MEM_wire_1:32'b0; 
assign address_out=(ID_EX_ctrl_wire[4]|ID_EX_ctrl_wire[3])?EX_MEM_wire_0:32'b0;
assign mem_read_ctrl=ID_EX_ctrl[4];
assign mem_write_ctrl=ID_EX_ctrl[3];
assign instr_addr=IF_ID_wire_1[13:2];
assign ALU_Output=EX_MEM_wire_0;

/*Pipelining */
always@(posedge clk) begin
            if(rst)
            begin
                {Instr,pc}<={32'b0,32'hx};
                {Instr_EX,Ra_data,Rb_data,offset,pc_EX}<={32'b0,32'hx,32'hx,32'hx,32'hx};
                {EX_MEM_funct3,MA_ALUResult}<={3'b0,32'hx};
                {MEM_WB[0],MEM_WB[1]}<={32'hx,32'hx};
                {ID_EX_ctrl[0],ID_EX_ctrl[1],ID_EX_ctrl[2],ID_EX_ctrl[3],ID_EX_ctrl[4],ID_EX_ctrl[5],ID_EX_ctrl[6],ID_EX_ctrl[7],ID_EX_ctrl[8]}<={1'b0,1'b0,1'bz,1'b0,1'b0,1'bz,1'b0,1'bz};
                {EX_MEM_ctrl[0],EX_MEM_ctrl[1]}<={1'bz,1'b0};
                {MEM_WB_ctrl[0],MEM_WB_ctrl[1]}<={1'bz,1'b0};
                {Ra,Rb,Rd}<={5'bx,5'bx,5'bx};
                {Ra_EX,Rb_EX,Rd_EX,EX_MEM_register,MEM_WB_register}<={5'bx,5'bx,5'bx,5'bx,5'bx};
            end
           else if(Branch_taken) 
           begin
                {Instr,pc}<={32'b0,32'hx};
                {Instr_EX,Ra_data,Rb_data,offset,pc_EX}<={32'b0,32'hx,32'hx,32'hx,32'hx};
                {ID_EX_ctrl[0],ID_EX_ctrl[1],ID_EX_ctrl[2],ID_EX_ctrl[3],ID_EX_ctrl[4],ID_EX_ctrl[5],ID_EX_ctrl[6],ID_EX_ctrl[7],ID_EX_ctrl[8]}<={1'b0,1'b0,1'bz,1'b0,1'b0,1'bz,1'b0,1'bz};
                {Ra,Rb,Rd}<={5'bx,5'bx,5'bx};
                {Ra_EX,Rb_EX,Rd_EX}<={5'bx,5'bx,5'bx};                
                {EX_MEM_funct3,MA_ALUResult}<={Instr[14:12],EX_MEM_wire_0};
                {EX_MEM_ctrl[0],EX_MEM_ctrl[1]}<={ID_EX_ctrl[5],ID_EX_ctrl[6]};
                {EX_MEM_register}<={Rd_EX};
                {MEM_WB[0],MEM_WB[1]}<={MA_ALUResult,MEM_WB_wire};
                {MEM_WB_ctrl[0],MEM_WB_ctrl[1]}<={EX_MEM_ctrl[0],EX_MEM_ctrl[1]};
                MEM_WB_register<=EX_MEM_register;
           end
           else 
           begin
           if(IF_ID_Write)
               begin
                {Instr,pc}<={IF_ID_wire_0,IF_ID_wire_1};
                {Ra,Rb,Rd}<={IF_ID_register_wire_0,IF_ID_register_wire_1,IF_ID_register_wire_2};
               end
           {Instr_EX,Ra_data,Rb_data,offset,pc_EX}<={Instr,ID_EX_wire_1,ID_EX_wire_2,ID_EX_wire_3,pc};
           {EX_MEM_funct3,MA_ALUResult}<={Instr[14:12],EX_MEM_wire_0};
           {MEM_WB[0],MEM_WB[1]}<={MA_ALUResult,MEM_WB_wire};
           {ID_EX_ctrl[0],ID_EX_ctrl[1],ID_EX_ctrl[2],ID_EX_ctrl[3],ID_EX_ctrl[4],ID_EX_ctrl[5],ID_EX_ctrl[6],ID_EX_ctrl[7],ID_EX_ctrl[8]}<={ID_EX_ctrl_wire[0],ID_EX_ctrl_wire[1],ID_EX_ctrl_wire[2],ID_EX_ctrl_wire[3],ID_EX_ctrl_wire[4],ID_EX_ctrl_wire[5],ID_EX_ctrl_wire[6],ID_EX_ctrl_wire[7],ID_EX_ctrl_wire[8]};
           {EX_MEM_ctrl[0],EX_MEM_ctrl[1]}<={ID_EX_ctrl[5],ID_EX_ctrl[6]};
           {MEM_WB_ctrl[0],MEM_WB_ctrl[1]}<={EX_MEM_ctrl[0],EX_MEM_ctrl[1]};
           {Ra_EX,Rb_EX,Rd_EX,EX_MEM_register,MEM_WB_register}<={Ra,Rb,Rd,Rd_EX,EX_MEM_register};
           end     
end

endmodule