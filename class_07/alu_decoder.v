`timescale 1ns / 1ps
//==============================================================================
// Week 7: ALU Decoder
// Decodes function field for R-type instructions (Synchronized with EX stage)
//==============================================================================
module alu_decoder (
    input  wire [1:0] alu_op,       // from main decoder
    input  wire [5:0] funct,        // R-type funct field
    output reg  [2:0] alu_ctrl      // to ALU
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 3'b010;  // ADD (lw/sw/addi)
            2'b01: alu_ctrl = 3'b110;  // SUB (beq)
            2'b10: begin               // R-type
                case (funct)
                    6'b100000: alu_ctrl = 3'b010; // add
                    6'b100010: alu_ctrl = 3'b110; // sub
                    6'b100100: alu_ctrl = 3'b000; // and
                    6'b100101: alu_ctrl = 3'b001; // or
                    6'b101010: alu_ctrl = 3'b111; // slt
                    default:   alu_ctrl = 3'b010;
                endcase
            end
            default: alu_ctrl = 3'b000;
        endcase
    end
endmodule