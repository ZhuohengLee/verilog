`timescale 1ns / 1ps

module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    output wire [31:0] instr,      // Fetched Instruction
    output wire [31:0] current_pc  // Current PC value (for debugging)
);

    // Internal Signals
    wire [31:0] pc;
    wire [31:0] pc_next;

    // ==========================================
    // 1. Instantiate Program Counter (PC)
    // ==========================================
    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc)
    );

    // ==========================================
    // 2. Adder Logic (PC Update)
    // ==========================================
    // MIPS instructions are 4 bytes wide, so Next PC = PC + 4
    assign pc_next = pc + 32'd4;

    // ==========================================
    // 3. Instantiate Instruction Memory
    // ==========================================
    // Note: Reusing the module from Week 3
    instruction_memory u_imem (
        .addr(pc),
        .rd(instr)
    );

    // Output current PC for observation
    assign current_pc = pc;

endmodule