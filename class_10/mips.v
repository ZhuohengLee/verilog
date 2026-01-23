`timescale 1ns / 1ps
module mips (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] pc_out,
    output wire [31:0] alu_result
);
    wire [31:0] instr_D;
    wire       reg_write_D, mem_to_reg_D, mem_write_D, branch_D;
    wire       alu_src_D, reg_dst_D;
    wire [2:0] alu_ctrl_D;
    wire [4:0] rs_D, rt_D, rs_E, rt_E, write_reg_E, write_reg_M, write_reg_W;
    wire       reg_write_M, reg_write_W, mem_to_reg_E;
    wire [1:0] forward_a_E, forward_b_E;
    wire       stall_F, stall_D, flush_E; 
    control_unit u_control (
        .opcode(instr_D[31:26]), .funct(instr_D[5:0]),
        .mem_to_reg(mem_to_reg_D), .mem_write(mem_write_D), .branch(branch_D),
        .alu_src(alu_src_D), .reg_dst(reg_dst_D), .reg_write(reg_write_D), .alu_ctrl(alu_ctrl_D)
    );
    hazard_unit u_hazard (
        .rs_E(rs_E), .rt_E(rt_E),
        .write_reg_M(write_reg_M), .reg_write_M(reg_write_M),
        .write_reg_W(write_reg_W), .reg_write_W(reg_write_W),
        .rs_D(rs_D), .rt_D(rt_D), .rt_E_load(rt_E), .mem_to_reg_E(mem_to_reg_E), 
        .forward_a_E(forward_a_E), .forward_b_E(forward_b_E),
        .stall_F(stall_F), .stall_D(stall_D), .flush_E(flush_E)
    );
    datapath u_datapath (
        .clk(clk), .rst_n(rst_n),
        .reg_write_D(reg_write_D), .mem_to_reg_D(mem_to_reg_D), .mem_write_D(mem_write_D),
        .alu_ctrl_D(alu_ctrl_D), .alu_src_D(alu_src_D), .reg_dst_D(reg_dst_D), .branch_D(branch_D),
        .forward_a_E(forward_a_E), .forward_b_E(forward_b_E),
        .stall_F(stall_F), .stall_D(stall_D), .flush_E(flush_E),
        .rs_D(rs_D), .rt_D(rt_D),
        .rs_E(rs_E), .rt_E(rt_E), 
        .write_reg_E(write_reg_E), .mem_to_reg_E(mem_to_reg_E),
        .write_reg_M(write_reg_M), .reg_write_M(reg_write_M), 
        .write_reg_W(write_reg_W), .reg_write_W(reg_write_W),
        .instr_D(instr_D), .pc_out(pc_out), .alu_result_out(alu_result)
    );
endmodule