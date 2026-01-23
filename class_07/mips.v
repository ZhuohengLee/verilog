`timescale 1ns / 1ps
//==============================================================================
// Week 7: Pipeline Integration - Top-level MIPS Module
// Focus: Orchestrating Control Signal Propagation
//
// In this stage, the Control Unit generates signals in the Decode (D) stage.
// The Pipelined Datapath is responsible for carrying these signals forward
// so they synchronize with the instruction as it matures.
//==============================================================================

module mips (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] pc_out,          // Current PC for debug
    output wire [31:0] alu_result       // Final result for debug
);

    // Instruction from Decode stage (for Control Unit)
    wire [31:0] instr_D;

    // Control signals (generated in Decode stage, propagated through pipeline)
    wire       reg_write_D, mem_to_reg_D, mem_write_D, branch_D;
    wire       alu_src_D, reg_dst_D;
    wire [2:0] alu_ctrl_D;

    // Control Unit
    control_unit u_control (
        .opcode(instr_D[31:26]),
        .funct(instr_D[5:0]),
        .mem_to_reg(mem_to_reg_D),
        .mem_write(mem_write_D),
        .branch(branch_D),
        .alu_src(alu_src_D),
        .reg_dst(reg_dst_D),
        .reg_write(reg_write_D),
        .alu_ctrl(alu_ctrl_D)
    );

    // Pipelined Datapath
    datapath u_datapath (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_D(reg_write_D),
        .mem_to_reg_D(mem_to_reg_D),
        .mem_write_D(mem_write_D),
        .alu_ctrl_D(alu_ctrl_D),
        .alu_src_D(alu_src_D),
        .reg_dst_D(reg_dst_D),
        .branch_D(branch_D),
        .instr_D(instr_D),
        .pc_out(pc_out),
        .alu_result_out(alu_result)
    );

endmodule