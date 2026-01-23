`timescale 1ns / 1ps

module datapath (
    input  wire        clk,
    input  wire        rst_n,
    // Control Signals (Driven by TB or Controller)
    input  wire        reg_write_en,   // enable writing to register file
    input  wire        reg_dst,        // select destination register: 0=rt, 1=rd
    input  wire        alu_src,        // select ALU second operand: 0=reg, 1=imm
    input  wire [2:0]  alu_ctrl,       // ALU operation selection
    input  wire        mem_write_en,   // enable writing to data memory (sw)
    input  wire        mem_to_reg,     // select write-back source: 0=ALU, 1=mem
    
    output wire [31:0] pc_out,         // current program counter for debug
    output wire [31:0] alu_result      // current ALU result for debug
);
    // Internal Interconnects
    wire [31:0] instr;                 // raw instruction from memory
    wire [31:0] pc;                    // internal PC value
    wire [31:0] rd1, rd2;              // outputs from register file
    wire [31:0] result;                // final data to write back to reg file
    wire [31:0] read_data;             // data loaded from memory
    wire [31:0] src_b;                 // second operand for ALU
    wire [4:0]  write_reg;             // selected destination register address
    wire [31:0] sign_imm;              // 32-bit sign-extended immediate
    wire        zero_flag;             // unused in Week 4, used for branches later

    // 1. Instruction Fetch Stage
    if_stage u_if_stage (
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),                 // output fetched machine code
        .current_pc(pc)                // output current PC
    );
    assign pc_out = pc;

    // 2. Decode Stage & Register File
    // Mux for Destination Register (rt or rd field)
    assign write_reg = (reg_dst) ? instr[15:11] : instr[20:16];
    
    reg_file u_reg_file (
        .clk(clk),
        .we3(reg_write_en),
        .ra1(instr[25:21]),            // rs field
        .ra2(instr[20:16]),            // rt field
        .wa3(write_reg),               // write destination
        .wd3(result),                  // data to write
        .rd1(rd1),                     // output operand A
        .rd2(rd2)                      // output operand B
    );

    // Sign Extension for I-type instructions
    assign sign_imm = {{16{instr[15]}}, instr[15:0]};

    // 3. Execution Stage (ALU)
    // Mux for ALU Source (Register or Immediate)
    assign src_b = (alu_src) ? sign_imm : rd2;
    
    alu u_alu (
        .src_a(rd1),
        .src_b(src_b),
        .alu_ctrl(alu_ctrl),
        .result(alu_result),
        .zero(zero_flag)
    );

    // 4. Data Memory Stage
    data_memory u_data_mem (
        .clk(clk),
        .mem_write_en(mem_write_en),
        .addr(alu_result),             // ALU result used as memory address
        .write_data(rd2),              // register rd2 used for store (sw)
        .read_data(read_data)          // data fetched from memory (lw)
    );

    // 5. Write-Back Stage
    // Mux for Data to Register File (Memory contents or ALU result)
    assign result = (mem_to_reg) ? read_data : alu_result;

endmodule