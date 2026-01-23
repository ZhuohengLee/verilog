`timescale 1ns / 1ps
module main_decoder (
    input  wire [5:0] opcode,
    output wire [1:0] mem_to_reg,
    output wire       mem_write,
    output wire       branch,
    output wire       alu_src,
    output wire [1:0] reg_dst,
    output wire       reg_write,
    output wire       jump,       
    output wire [1:0] alu_op
);
    reg [11:0] controls;
    assign {reg_write, reg_dst, alu_src, branch, mem_write, mem_to_reg, jump, alu_op} = controls;
    always @(*) begin
        case (opcode)
            6'b000000: controls = 12'b1_01_0_0_0_00_0_10; 
            6'b100011: controls = 12'b1_00_1_0_0_01_0_00; 
            6'b101011: controls = 12'b0_00_1_0_1_00_0_00; 
            6'b000100: controls = 12'b0_00_0_1_0_00_0_01; 
            6'b001000: controls = 12'b1_00_1_0_0_00_0_00; 
            6'b000010: controls = 12'b0_00_0_0_0_00_1_00; 
            6'b000011: controls = 12'b1_10_0_0_0_10_1_00; 
            default:   controls = 12'b0_00_0_0_0_00_0_00;
        endcase
    end
endmodule