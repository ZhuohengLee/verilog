`timescale 1ns / 1ps
module main_decoder (
    input  wire [5:0] opcode,
    output wire       mem_to_reg,   // 1=mem data, 0=ALU
    output wire       mem_write,    // sw
    output wire       branch,       // beq
    output wire       alu_src,      // 1=imm, 0=reg
    output wire       reg_dst,      // 1=rd, 0=rt
    output wire       reg_write,    // write enable
    output wire [1:0] alu_op        // to ALU decoder
);
    reg [8:0] controls;
    assign {reg_write, reg_dst, alu_src, branch, mem_write, mem_to_reg, alu_op} = controls;
    
    always @(*) begin
        case (opcode)
            6'b000000: controls = 9'b1_1_0_0_0_0_10; // R-type
            6'b100011: controls = 9'b1_0_1_0_0_1_00; // lw
            6'b101011: controls = 9'b0_0_1_0_1_0_00; // sw
            6'b000100: controls = 9'b0_0_0_1_0_0_01; // beq
            6'b001000: controls = 9'b1_0_1_0_0_0_00; // addi
            default:   controls = 9'b0_0_0_0_0_0_00;
        endcase
    end
endmodule