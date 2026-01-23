`timescale 1ns / 1ps

module data_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 256
)(
    input  wire        clk,
    input  wire        mem_write_en,  // Memory Write Enable (for sw)
    input  wire [31:0] addr,          // Address (from ALU)
    input  wire [31:0] write_data,    // Data to write (from RegFile rd2)
    output wire [31:0] read_data      // Data read out (for lw)
);

    reg [WIDTH-1:0] ram [0:DEPTH-1];

    // Read Logic (Combinational)
    // Similar to IM, map byte address to word index
    assign read_data = ram[addr[31:2]];

    // Write Logic (Sequential)
    always @(posedge clk) begin
        if (mem_write_en) begin
            ram[addr[31:2]] <= write_data;
        end
    end

endmodule