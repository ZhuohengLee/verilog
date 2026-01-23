`timescale 1ns / 1ps
module alu (
    input  wire [31:0] src_a,      // first operand
    input  wire [31:0] src_b,      // second operand
    input  wire [2:0]  alu_ctrl,   // operation control signal
    output reg  [31:0] result,     // arithmetic or logic result
    output wire        zero        // zero flag: 1 if result is zero
);
    always @(*) begin              // combinatorial logic
        case (alu_ctrl)            // select operation
            3'b000: result = src_a & src_b;                        // bitwise AND
            3'b001: result = src_a | src_b;                        // bitwise OR
            3'b010: result = src_a + src_b;                        // addition
            3'b110: result = src_a - src_b;                        // subtraction
            3'b111: result = ($signed(src_a) < $signed(src_b)) ? 1 : 0; // set less than
            default: result = 32'd0;                               // default result
        endcase
    end
    assign zero = (result == 32'd0); // output zero flag
endmodule