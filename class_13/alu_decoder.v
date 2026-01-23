`timescale 1ns / 1ps
module alu_decoder (
    input  wire [5:0] funct,
    input  wire [1:0] alu_op,
    output reg  [2:0] alu_ctrl
);
    always @(*) begin
        case (alu_op)
            2'b00: alu_ctrl = 3'b010; 
            2'b01: alu_ctrl = 3'b110; 
            2'b10: begin 
                case (funct)
                    6'b100000: alu_ctrl = 3'b010; 
                    6'b100010: alu_ctrl = 3'b110; 
                    6'b100100: alu_ctrl = 3'b000; 
                    6'b100101: alu_ctrl = 3'b001; 
                    6'b101010: alu_ctrl = 3'b111; 
                    default:   alu_ctrl = 3'b000;
                endcase
            end
            default: alu_ctrl = 3'b000;
        endcase
    end
endmodule