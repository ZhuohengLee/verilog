`timescale 1ns / 1ps
module alu_decoder (
    input  wire [1:0] alu_op,       // ALU operation type from main decoder
    input  wire [5:0] funct,        // function field for R-type instructions
    output reg  [2:0] alu_ctrl      // ALU control signal output
);
    always @(*) begin              // combinatorial logic
        case (alu_op)              // decode based on alu_op
            2'b00: alu_ctrl = 3'b010;  // addition (for lw/sw/addi)
            2'b01: alu_ctrl = 3'b110;  // subtraction (for beq)
            2'b10: begin               // R-type instruction
                case (funct)           // decode based on function field
                    6'b100000: alu_ctrl = 3'b010; // add
                    6'b100010: alu_ctrl = 3'b110; // sub
                    6'b100100: alu_ctrl = 3'b000; // and
                    6'b100101: alu_ctrl = 3'b001; // or
                    6'b101010: alu_ctrl = 3'b111; // slt
                    default:   alu_ctrl = 3'b010; // default to add
                endcase
            end
            default: alu_ctrl = 3'b000; // default case
        endcase
    end
endmodule