`timescale 1ns / 1ps
module control_unit (
    input  wire [5:0] opcode,       // instruction opcode field
    input  wire [5:0] funct,        // instruction function field
    
    output wire       mem_to_reg,   // memory to register select
    output wire       mem_write,    // memory write enable
    output wire       branch,       // branch enable
    output wire       alu_src,      // ALU source select
    output wire       reg_dst,      // register destination select
    output wire       reg_write,    // register write enable
    output wire [2:0] alu_ctrl      // ALU control signal
);
    wire [1:0] alu_op;              // ALU operation type
    
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