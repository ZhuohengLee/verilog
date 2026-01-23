`timescale 1ns / 1ps
module control_unit (
    input  wire [5:0] opcode,       // instr[31:26]
    input  wire [5:0] funct,        // instr[5:0]
    output wire       mem_to_reg,
    output wire       mem_write,
    output wire       branch,
    output wire       alu_src,
    output wire       reg_dst,
    output wire       reg_write,
    output wire [2:0] alu_ctrl
);
    wire [1:0] alu_op;
    
    main_decoder u_main_dec (
        .opcode(opcode),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .branch(branch),
        .alu_src(alu_src),
        .reg_dst(reg_dst),
        .reg_write(reg_write),
        .alu_op(alu_op)
    );
    
    alu_decoder u_alu_dec (
        .alu_op(alu_op),
        .funct(funct),
        .alu_ctrl(alu_ctrl)
    );
endmodule