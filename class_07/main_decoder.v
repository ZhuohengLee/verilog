`timescale 1ns / 1ps
//==============================================================================
// Week 7: Main Decoder
// Decodes opcode to generate a multi-bit control vector
//==============================================================================

module main_decoder (
    input  wire [5:0] opcode,
    
    // These signals are pipelined in the datapath to reach their target stages
    output wire       mem_to_reg,   // [WB stage]  1=mem data, 0=ALU
    output wire       mem_write,    // [MEM stage] Write enable for Data Memory
    output wire       branch,       // [MEM stage] Branch logic enable
    output wire       alu_src,      // [EX stage]  1=imm, 0=reg
    output wire       reg_dst,      // [EX stage]  Selects rt or rd for destination
    output wire       reg_write,    // [WB stage]  Write enable for Register File
    output wire [1:0] alu_op        // [To ALU Decoder]
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