`timescale 1ns / 1ps

module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    // Branching Signals (New)
    input  wire        pc_src,        // 0 = Next (PC+4), 1 = Branch Target
    input  wire [31:0] branch_target, // Address to jump to
    output wire [31:0] instr,
    output wire [31:0] current_pc
);

    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;

    // 1. PC Register
    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc)
    );

    // 2. Next PC Logic
    assign pc_plus4 = pc + 32'd4;

    // MUX: Select between PC+4 and Branch Target
    assign pc_next = (pc_src) ? branch_target : pc_plus4;

    // 3. Instruction Memory
    instruction_memory u_imem (
        .addr(pc),
        .rd(instr)
    );

    assign current_pc = pc;

endmodule