`timescale 1ns / 1ps

module datapath (
    input  wire        clk,
    input  wire        rst_n,
    // Control Signals
    input  wire        reg_write_en,
    input  wire        reg_dst,
    input  wire        alu_src,
    input  wire [2:0]  alu_ctrl,
    input  wire        mem_write_en,
    input  wire        mem_to_reg,
    input  wire        branch,       // NEW: From Control Unit
    
    // Outputs
    output wire [31:0] pc_out,
    output wire [31:0] alu_result,
    output wire [31:0] instr_out
);

    // Internal Wires
    wire [31:0] instr;
    wire [31:0] pc;
    wire [31:0] rd1, rd2;
    wire [31:0] result;
    wire [31:0] read_data;
    wire [31:0] src_b;
    wire [4:0]  write_reg;
    wire [31:0] sign_imm;
    wire        zero_flag;
    
    // Branching Wires (New)
    wire [31:0] pc_plus4;
    wire [31:0] branch_target;
    wire        pc_src;

    // Output instruction to Control Unit
    assign instr_out = instr;

    // ==================================================
    // 1. Branch Logic Calculation
    // ==================================================
    assign pc_plus4 = pc + 32'd4;
    
    // Target = (PC + 4) + (SignImm << 2)
    assign branch_target = pc_plus4 + (sign_imm << 2);

    // PCSrc = 1 if Branch instruction is active AND ALU Zero flag is set
    assign pc_src = branch & zero_flag;

    // ==================================================
    // 2. IF Stage (Updated Instantiation)
    // ==================================================
    if_stage u_if_stage (
        .clk(clk),
        .rst_n(rst_n),
        .pc_src(pc_src),            // Connect Mux Select
        .branch_target(branch_target), // Connect Target Address
        .instr(instr),
        .current_pc(pc)
    );

    assign pc_out = pc;

    // ==================================================
    // 3. Decode & RegFile
    // ==================================================
    assign write_reg = (reg_dst) ? instr[15:11] : instr[20:16];
    assign result    = (mem_to_reg) ? read_data : alu_result;

    reg_file u_reg_file (
        .clk(clk),
        .we3(reg_write_en),
        .ra1(instr[25:21]),
        .ra2(instr[20:16]),
        .wa3(write_reg),
        .wd3(result),
        .rd1(rd1),
        .rd2(rd2)
    );

    assign sign_imm = {{16{instr[15]}}, instr[15:0]};

    // ==================================================
    // 4. Execution (ALU)
    // ==================================================
    assign src_b = (alu_src) ? sign_imm : rd2;

    alu u_alu (
        .src_a(rd1),
        .src_b(src_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero_flag)
    );

    // ==================================================
    // 5. Memory
    // ==================================================
    data_memory u_data_mem (
        .clk(clk),
        .mem_write_en(mem_write_en),
        .addr(alu_result),
        .write_data(rd2),
        .read_data(read_data)
    );

endmodule