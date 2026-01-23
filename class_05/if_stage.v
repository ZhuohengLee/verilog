`timescale 1ns / 1ps
module if_stage (
    input  wire        clk,            // clock signal
    input  wire        rst_n,          // active-low reset
    input  wire        pc_src,         // next PC source select: 0=PC+4, 1=branch
    input  wire [31:0] branch_target,  // calculated branch target address
    output wire [31:0] instr,          // instruction fetched from memory
    output wire [31:0] current_pc      // current PC value (for debug)
);
    wire [31:0] pc;                    // current program counter
    wire [31:0] pc_next;               // next program counter
    wire [31:0] pc_plus4;              // sequential PC (PC+4)
    
    pc u_pc (                          // program counter register
        .clk(clk),                     // clock
        .rst_n(rst_n),                 // reset
        .pc_next(pc_next),             // input: next PC
        .pc(pc)                        // output: current PC
    );
    
    assign pc_plus4 = pc + 32'd4;                    // sequential increment
    assign pc_next = (pc_src) ? branch_target : pc_plus4;  // next PC mux
    
    instruction_memory u_imem (        // instruction memory module
        .addr(pc),                     // address input
        .rd(instr)                     // instruction output
    );
    
    assign current_pc = pc;            // expose current PC for debug
endmodule