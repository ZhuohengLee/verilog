`timescale 1ns / 1ps
module if_stage (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        pc_src,         // 0=PC+4, 1=branch
    input  wire [31:0] branch_target,  // branch address
    output wire [31:0] instr,          // fetched instruction
    output wire [31:0] current_pc      // current PC
);
    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] pc_plus4;
    
    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next),
        .pc(pc)
    );
    
    assign pc_plus4 = pc + 32'd4;                    // sequential
    assign pc_next = (pc_src) ? branch_target : pc_plus4;  // MUX
    
    instruction_memory u_imem (
        .addr(pc),
        .rd(instr)
    );
    
    assign current_pc = pc;                          // debug
endmodule