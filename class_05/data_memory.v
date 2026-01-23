`timescale 1ns / 1ps
module data_memory #(
    parameter WIDTH = 32,             // data width
    parameter DEPTH = 256             // memory depth (256 words = 1KB)
)(
    input  wire        clk,           // clock signal
    input  wire        mem_write_en,  // write enable (for sw instruction)
    input  wire [31:0] addr,          // memory address (byte address)
    input  wire [31:0] write_data,    // data to be written
    output wire [31:0] read_data      // data read from memory (for lw instruction)
);
    reg [WIDTH-1:0] ram [0:DEPTH-1];  // internal memory array
    
    assign read_data = ram[addr[31:2]];  // read operation (word aligned)
    
    always @(posedge clk) begin       // synchronous write
        if (mem_write_en)             // check write enable
            ram[addr[31:2]] <= write_data;  // write operation (word aligned)
    end
endmodule