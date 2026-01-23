`timescale 1ns / 1ps
module data_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 256
)(
    input  wire        clk,
    input  wire        mem_write_en,  
    input  wire [31:0] addr,          
    input  wire [31:0] write_data,    
    output wire [31:0] read_data      
);
    reg [WIDTH-1:0] ram [0:DEPTH-1];
    assign read_data = ram[addr[31:2]];
    always @(posedge clk) begin
        if (mem_write_en) begin
            ram[addr[31:2]] <= write_data;
        end
    end
endmodule