`timescale 1ns / 1ps

module main_decoder (
    input  wire [5:0] opcode,
    output wire       mem_to_reg,
    output wire       mem_write,
    output wire       branch,
    output wire       alu_src,
    output wire       reg_dst,
    output wire       reg_write,
    output wire [1:0] alu_op    // Sent to ALU Decoder
);

    reg [8:0] controls; // Temporary bundle for signals

    // Output assignment
    assign {reg_write, reg_dst, alu_src, branch, mem_write, mem_to_reg, alu_op} = controls;

    always @(*) begin
        case (opcode)
            6'b000000: controls = 9'b1_1_0_0_0_0_10; // R-Type (add, sub, etc.)
            6'b100011: controls = 9'b1_0_1_0_0_1_00; // lw
            6'b101011: controls = 9'b0_0_1_0_1_0_00; // sw
            6'b000100: controls = 9'b0_0_0_1_0_0_01; // beq
            6'b001000: controls = 9'b1_0_1_0_0_0_00; // addi (Treat as lw but no mem read)
            default:   controls = 9'b0_0_0_0_0_0_00; // Illegal opcode
        endcase
    end

endmodule