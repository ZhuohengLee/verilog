`timescale 1ns / 1ps
module mips (
    input  wire        clk,            // clock signal
    input  wire        rst_n,          // active-low asynchronous reset
    output wire [31:0] pc_out,         // current program counter (output for debug)
    output wire [31:0] alu_result      // ALU result (output for debug)
);
    // Control signals
    wire       mem_to_reg;             // memory to register write-back select
    wire       mem_write;              // data memory write enable
    wire       branch;                 // branch enable signal
    wire       alu_src;                // ALU operand B source select
    wire       reg_dst;                // register destination select
    wire       reg_write;              // register file write enable
    wire [2:0] alu_ctrl;               // ALU control signal
    wire [31:0] instr;                 // current instruction fetched from memory
    
    control_unit u_control (           // control unit module
        .opcode(instr[31:26]),         // input: instruction opcode
        .funct(instr[5:0]),            // input: instruction function field
        .mem_to_reg(mem_to_reg),       // output: mem_to_reg control
        .mem_write(mem_write),         // output: mem_write control
        .branch(branch),               // output: branch control
        .alu_src(alu_src),             // output: alu_src control
        .reg_dst(reg_dst),             // output: reg_dst control
        .reg_write(reg_write),         // output: reg_write control
        .alu_ctrl(alu_ctrl)            // output: alu_ctrl control
    );
    
    datapath u_datapath (              // datapath module
        .clk(clk),                     // clock
        .rst_n(rst_n),                 // reset
        .reg_write_en(reg_write),      // control: reg_write
        .reg_dst(reg_dst),             // control: reg_dst
        .alu_src(alu_src),             // control: alu_src
        .alu_ctrl(alu_ctrl),           // control: alu_ctrl
        .mem_write_en(mem_write),      // control: mem_write
        .mem_to_reg(mem_to_reg),       // control: mem_to_reg
        .branch(branch),               // control: branch
        .pc_out(pc_out),               // output: current PC
        .alu_result(alu_result),       // output: ALU result
        .instr_out(instr)              // output: fetched instruction
    );
endmodule