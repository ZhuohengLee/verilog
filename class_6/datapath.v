`timescale 1ns / 1ps

module datapath (
    input  wire        clk,
    input  wire        rst_n,
    // Control Signals (Driven by Control Unit in Week 6)
    input  wire        reg_write_en, // Write to Register File?
    input  wire        reg_dst,      // 0=Rt (I-Type), 1=Rd (R-Type)
    input  wire        alu_src,      // 0=RegB, 1=Imm
    input  wire [2:0]  alu_ctrl,     // ALU Control Signal
    input  wire        mem_write_en, // Write to Data Memory?
    input  wire        mem_to_reg,   // 0=ALU Result, 1=Mem Data
    
    // Outputs
    output wire [31:0] pc_out,
    output wire [31:0] alu_result,
    output wire [31:0] instr_out     // <--- NEW: Output Instruction to Control Unit
);

    // Internal Wires
    wire [31:0] instr;
    wire [31:0] pc;
    wire [31:0] rd1, rd2;
    wire [31:0] result;      // Final data to write back to RegFile
    wire [31:0] read_data;   // Data from Data Memory
    wire [31:0] src_b;       // ALU Operand B (after Mux)
    wire [4:0]  write_reg;   // Destination Register (after Mux)
    wire [31:0] sign_imm;    // Sign-Extended Immediate
    wire        zero_flag;   // ALU Zero Flag

    
    assign instr_out = instr; 

    // ==================================================
    // 1. Instruction Fetch (IF) Stage
    // ==================================================
    if_stage u_if_stage (
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),     // Fetched instruction
        .current_pc(pc)
    );

    assign pc_out = pc; // Debug output

    // ==================================================
    // 2. Decode / Register File Read
    // ==================================================
    // Logic: Mux for Write Register Address (RegDst)
    // if reg_dst==1, write to Rd (instr[15:11]), else Rt (instr[20:16])
    assign write_reg = (reg_dst) ? instr[15:11] : instr[20:16];

    // Logic: Mux for Write Data (MemtoReg)
    // if mem_to_reg==1, data from Mem, else from ALU
    assign result = (mem_to_reg) ? read_data : alu_result;

    reg_file u_reg_file (
        .clk(clk),
        .we3(reg_write_en),
        .ra1(instr[25:21]), // rs
        .ra2(instr[20:16]), // rt
        .wa3(write_reg),    // Determined by RegDst Mux
        .wd3(result),       // Determined by MemtoReg Mux
        .rd1(rd1),
        .rd2(rd2)
    );

    // Logic: Sign Extension (16-bit to 32-bit)
    assign sign_imm = {{16{instr[15]}}, instr[15:0]};

    // ==================================================
    // 3. Execution (ALU)
    // ==================================================
    // Logic: Mux for ALU Source B (ALUSrc)
    // if alu_src==1, use Immediate, else use Register B (rd2)
    assign src_b = (alu_src) ? sign_imm : rd2;

    alu u_alu (
        .src_a(rd1),
        .src_b(src_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero_flag)
    );

    // ==================================================
    // 4. Memory Access
    // ==================================================
    data_memory u_data_mem (
        .clk(clk),
        .mem_write_en(mem_write_en),
        .addr(alu_result), // Address comes from ALU
        .write_data(rd2),  // Data to store comes from Reg B
        .read_data(read_data)
    );

endmodule