`timescale 1ns / 1ps

module datapath (
    input  wire        clk,            // clock signal
    input  wire        rst_n,          // active-low asynchronous reset
    // Control Signals
    input  wire        reg_write_en,   // enable writing to register file
    input  wire        reg_dst,        // select destination register: 0=rt, 1=rd
    input  wire        alu_src,        // select ALU second operand: 0=reg, 1=imm
    input  wire [2:0]  alu_ctrl,       // ALU operation selection
    input  wire        mem_write_en,   // enable writing to data memory (sw)
    input  wire        mem_to_reg,     // select write-back source: 0=ALU, 1=mem
    input  wire        branch,         // enable branch (beq)
    
    output wire [31:0] pc_out,         // current PC value for debug/monitoring
    output wire [31:0] alu_result,     // ALU result for debug/monitoring
    output wire [31:0] instr_out       // raw instruction for control unit
);
    // Internal Interconnects
    wire [31:0] instr;                 // fetched instruction
    wire [31:0] pc;                    // current program counter
    wire [31:0] rd1, rd2;              // register read data 1 and 2
    wire [31:0] result;                // final result for write-back
    wire [31:0] read_data;             // data read from data memory
    wire [31:0] src_b;                 // second operand for ALU
    wire [4:0]  write_reg;             // destination register address
    wire [31:0] sign_imm;              // sign-extended immediate value
    wire        zero_flag;             // ALU zero flag for branching
    
    // Branching Logic Signals
    wire [31:0] pc_plus4;              // PC + 4 (next sequential instruction)
    wire [31:0] branch_target;         // calculated branch target address
    wire        pc_src;                // PC source select: 0=PC+4, 1=branch
    
    assign instr_out = instr;          // output instruction to control unit
    
    // 1. Branch Address & Control Logic
    assign pc_plus4 = pc + 32'd4;      // calculate sequential PC
    assign branch_target = pc_plus4 + (sign_imm << 2);  // calculate branch target
    assign pc_src = branch & zero_flag;                 // determine if branch is taken

    // 2. Instruction Fetch Stage
    if_stage u_if_stage (
        .clk(clk),                     // clock
        .rst_n(rst_n),                 // reset
        .pc_src(pc_src),               // branch select signal
        .branch_target(branch_target), // branch target address
        .instr(instr),                 // fetched instruction
        .current_pc(pc)                // current PC value
    );
    assign pc_out = pc;                // output current PC

    // 3. Decode Stage & Register File
    // Mux for Destination Register
    assign write_reg = (reg_dst) ? instr[15:11] : instr[20:16]; // select rd or rt
    
    reg_file u_reg_file (
        .clk(clk),                     // clock
        .we3(reg_write_en),            // register write enable
        .ra1(instr[25:21]),            // rs register address
        .ra2(instr[20:16]),            // rt register address
        .wa3(write_reg),               // destination register address
        .wd3(result),                  // data to write to register
        .rd1(rd1),                     // register read data 1
        .rd2(rd2)                      // register read data 2
    );

    // Sign Extension for constants
    assign sign_imm = {{16{instr[15]}}, instr[15:0]}; // extend 16-bit to 32-bit

    // 4. Execution Stage (ALU)
    // Mux for ALU Source
    assign src_b = (alu_src) ? sign_imm : rd2; // select immediate or register data
    
    alu u_alu (
        .src_a(rd1),                   // ALU operand A
        .src_b(src_b),                 // ALU operand B
        .alu_ctrl(alu_ctrl),           // ALU control signal
        .result(alu_result),           // ALU operation result
        .zero(zero_flag)               // ALU zero flag
    );

    // 5. Data Memory Stage
    data_memory u_data_mem (
        .clk(clk),                     // clock
        .mem_write_en(mem_write_en),   // memory write enable
        .addr(alu_result),             // memory address
        .write_data(rd2),              // data to write to memory
        .read_data(read_data)          // data read from memory
    );

    // 6. Write-Back Stage
    // Mux for Write-back data
    assign result = (mem_to_reg) ? read_data : alu_result; // select memory or ALU result

endmodule