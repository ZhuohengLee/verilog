`timescale 1ns / 1ps

module mips (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] pc_out,
    output wire [31:0] alu_result
);

    // Wires connecting Control Unit and Datapath
    wire       mem_to_reg;
    wire       mem_write;
    wire       branch;
    wire       alu_src;
    wire       reg_dst;
    wire       reg_write;
    wire [2:0] alu_ctrl;
    wire [31:0] instr;

    // 1. Instantiate Control Unit
    control_unit u_control (
        .opcode(instr[31:26]),
        .funct(instr[5:0]),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .branch(branch),
        .alu_src(alu_src),
        .reg_dst(reg_dst),
        .reg_write(reg_write),
        .alu_ctrl(alu_ctrl)
    );

    // 2. Instantiate Datapath
    // Note: Make sure your datapath.v has 'instr_out' port!
    datapath u_datapath (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_en(reg_write),  // Connected to Control Unit
        .reg_dst(reg_dst),         // Connected to Control Unit
        .alu_src(alu_src),         // Connected to Control Unit
        .alu_ctrl(alu_ctrl),       // Connected to Control Unit
        .mem_write_en(mem_write),  // Connected to Control Unit
        .mem_to_reg(mem_to_reg),   // Connected to Control Unit
        .branch(branch),           // Connected to Control Unit
        .pc_out(pc_out),
        .alu_result(alu_result),
        .instr_out(instr)          // Feedback instruction to Control Unit
    );

endmodule               