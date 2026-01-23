`timescale 1ns / 1ps

module alu (
    input  wire [31:0] src_a,
    input  wire [31:0] src_b,
    input  wire [2:0]  alu_ctrl,
    output reg  [31:0] result,
    output wire        zero
);

    always @(*) begin
        case (alu_ctrl)
            3'b000: result = src_a & src_b; // AND
            3'b001: result = src_a | src_b; // OR
            3'b010: result = src_a + src_b; // ADD
            3'b110: result = src_a - src_b; // SUB
            3'b111: begin                   // SLT
                if ($signed(src_a) < $signed(src_b)) 
                    result = 32'd1;
                else 
                    result = 32'd0;
            end
            default: result = 32'd0;
        endcase
    end

    assign zero = (result == 32'd0);

endmodule