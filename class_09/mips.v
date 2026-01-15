`timescale 1ns / 1ps

module mips (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] pc_out,
    output wire [31:0] alu_result
);

    wire [31:0] instr_D;
    
    // Control Signals
    wire       reg_write_D, mem_to_reg_D, mem_write_D, branch_D;
    wire       alu_src_D, reg_dst_D;
    wire [2:0] alu_ctrl_D;

    // Hazard/Forwarding Wires
    wire [4:0] rs_E, rt_E, write_reg_M, write_reg_W;
    wire       reg_write_M, reg_write_W;
    wire [1:0] forward_a_E, forward_b_E;

    // 1. Control Unit
    control_unit u_control (
        .opcode(instr_D[31:26]), .funct(instr_D[5:0]),
        .mem_to_reg(mem_to_reg_D), .mem_write(mem_write_D), .branch(branch_D),
        .alu_src(alu_src_D), .reg_dst(reg_dst_D), .reg_write(reg_write_D), .alu_ctrl(alu_ctrl_D)
    );

    // 2. Forwarding Unit (The new "Traffic Controller")
    forwarding_unit u_forwarding (
        .rs_E(rs_E), .rt_E(rt_E),
        .write_reg_M(write_reg_M), .reg_write_M(reg_write_M),
        .write_reg_W(write_reg_W), .reg_write_W(reg_write_W),
        .forward_a_E(forward_a_E), .forward_b_E(forward_b_E)
    );

    // 3. Datapath (Connected with Forwarding Signals)
    datapath u_datapath (
        .clk(clk), .rst_n(rst_n),
        .reg_write_D(reg_write_D), .mem_to_reg_D(mem_to_reg_D), .mem_write_D(mem_write_D),
        .alu_ctrl_D(alu_ctrl_D), .alu_src_D(alu_src_D), .reg_dst_D(reg_dst_D), .branch_D(branch_D),
        // Forwarding Connections
        .forward_a_E(forward_a_E), .forward_b_E(forward_b_E),
        .rs_E(rs_E), .rt_E(rt_E), 
        .write_reg_M(write_reg_M), .reg_write_M(reg_write_M), 
        .write_reg_W(write_reg_W), .reg_write_W(reg_write_W),
        // Outputs
        .instr_D(instr_D), .pc_out(pc_out), .alu_result_out(alu_result)
    );

endmodule