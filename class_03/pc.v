`timescale 1ns / 1ps
module pc (
    input  wire        clk,
    input  wire        rst_n,      // async reset (active low)
    input  wire [31:0] pc_next,    // next PC value
    output reg  [31:0] pc          // current PC
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'd0;           // reset to 0
        else
            pc <= pc_next;         // update PC
    end
endmodule