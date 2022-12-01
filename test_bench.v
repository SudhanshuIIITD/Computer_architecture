`timescale 1ns / 1ps

module test_bench();
reg clk=1'b1,rst=1'b1;
wire [31:0] Ra_data,Rb_data,offset,Instr,pc,target_pc,mem_ALUResult,ALU_Output,data_in,data_out,address_out,WB_data;
parameter BOOT_ADDRESS=32'b0;
wire [4:0] Ra,Rb,Rd;
wire invalid,PCWrite,RegWrite,MemRead,MemWrite,MemtoReg,select_control_unit,is_Branch,IF_ID_Write,branch_taken;
wire [11:0]instr_addr;

top_module tm(.clk(clk),.rst(rst),.Instr_in(Instr),.pc(pc),.Ra(Ra),.Rb(Rb),.Rd(Rd),.instr_addr(instr_addr),.Ra_data(Ra_data),.Rb_data(Rb_data),.offset(offset),.Branch_taken(branch_taken),.target_pc(target_pc),.MA_ALUResult(mem_ALUResult),.data_out(data_out),
.address_out(address_out),.ALU_Output(ALU_Output),.mem_read_ctrl(MemRead),.mem_write_ctrl(MemWrite),.data_in(data_in),.temp(WB_data));
Instr_Memory IM(.clk(clk),.address(instr_addr),.instr(Instr));
data_memory DM(.clk(clk),.mem_read_ctrl(MemRead),.mem_write_ctrl(MemWrite),.mem_address(address_out[13:2]),.mem_data_write(data_out),.mem_data_read(data_in));

initial
    begin
    forever
        begin
        #5 clk=~clk;
        end
    end
initial
    begin
    #5 rst=1'b0;
    #1000 $finish;
    end
endmodule
