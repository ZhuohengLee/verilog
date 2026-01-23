`timescale 1ns / 1ps
module control_unit (
    input  wire [5:0] opcode,
    input  wire [5:0] funct,
    output wire       mem_to_reg_bit1, mem_to_reg_bit0,
    output wire       mem_write,
    output wire       branch,
    output wire       alu_src,
    output wire       reg_dst_bit1, reg_dst_bit0,
    output wire       reg_write,
    output wire       jump,
    output wire       jr,
    output wire [2:0] alu_ctrl
);
    wire [1:0] alu_op, mem_to_reg, reg_dst;
    main_decoder u_main_decoder (
        .opcode(opcode), .mem_to_reg(mem_to_reg), .mem_write(mem_write),
        .branch(branch), .alu_src(alu_src), .reg_dst(reg_dst),
        .reg_write(reg_write), .jump(jump), .alu_op(alu_op)
    );
    alu_decoder u_alu_decoder (.funct(funct), .alu_op(alu_op), .alu_ctrl(alu_ctrl));
    assign mem_to_reg_bit1 = mem_to_reg[1];
    assign mem_to_reg_bit0 = mem_to_reg[0];
    assign reg_dst_bit1 = reg_dst[1];
    assign reg_dst_bit0 = reg_dst[0];
    assign jr = (alu_op == 2'b10) && (funct == 6'b001000);
endmodule