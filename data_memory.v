`timescale 1ns / 1ps

module data_memory(clk,mem_read_ctrl,mem_write_ctrl,mem_address,
mem_data_write,mem_data_read);

input mem_read_ctrl;
input mem_write_ctrl;
input clk;
input [11:0] mem_address;//We need atleast 12 bits in the address to access 4K data words.
input [31:0] mem_data_write;
output reg [31:0]mem_data_read;
reg [31:0]mem_data_temp;
reg [11:0]mem_address_temp;
reg temp;
/*RAM*/
reg [31:0] mem_ram [0:4095];  //16KB of data memory, 4K data words present in the memory

always@(posedge clk)
begin
    if(mem_read_ctrl || mem_write_ctrl)
    begin
        if(mem_read_ctrl)
            mem_data_read=mem_ram[mem_address]; //load
        else
            mem_data_read=32'b0;//In case of store
            
        if(!mem_read_ctrl && mem_write_ctrl) //store the data into the memory
        begin
            mem_ram[mem_address]=mem_data_write;
        end
    end
end

always @(posedge clk)
begin
    if(mem_read_ctrl && mem_write_ctrl)
        begin
            temp<=1;
            mem_data_temp<=mem_data_write;
            mem_address_temp<=mem_address;
        end
    else
        begin
            temp<=0;
            mem_data_temp<=32'b0;
            mem_address_temp<=12'b0;
        end
end

always @ (negedge clk)
begin
    if(temp)
        mem_ram[mem_address_temp]=mem_data_temp;
end

endmodule
