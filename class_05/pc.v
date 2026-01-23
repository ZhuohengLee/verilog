`timescale 1ns / 1ps
module pc (
    input  wire        clk,            // clock signal
    input  wire        rst_n,          // active-low asynchronous reset
    input  wire [31:0] pc_next,        // input: next value of the program counter
    output reg  [31:0] pc              // output: current value of the program counter
);
    always @(posedge clk or negedge rst_n) begin // synchronous update, async reset
        if (!rst_n)                    // check for reset
            pc <= 32'd0;               // reset program counter to 0
        else                           // normal operation
            pc <= pc_next;             // update PC with next value
    end
endmodule