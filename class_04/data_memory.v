`timescale 1ns / 1ps
module data_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 256             // 256 words = 1KB
)(
    input  wire        clk,
    input  wire        mem_write_en,  // write enable (sw)
    input  wire [31:0] addr,          // byte address
    input  wire [31:0] write_data,    // data to write
    output wire [31:0] read_data      // data read (lw)
);
    reg [WIDTH-1:0] ram [0:DEPTH-1];
    
    assign read_data = ram[addr[31:2]];  // word aligned read
    
    always @(posedge clk) begin
        if (mem_write_en)
            ram[addr[31:2]] <= write_data;  // word aligned write
    end
endmodule