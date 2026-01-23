`timescale 1ns / 1ps
//==============================================================================
// Week 7: Program Counter Register
// Simple version for basic pipeline structure (Stall/Forwarding comes later)
//==============================================================================

module pc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc_next,
    output reg  [31:0] pc
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pc <= 32'b0;
        else
            pc <= pc_next;
    end

endmodule