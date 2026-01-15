`timescale 1ns / 1ps

module datapath (
    input  wire        clk,
    input  wire        rst_n,
    // Control Signals (from Control Unit, generated in ID stage)
    input  wire        reg_write_D,
    input  wire        mem_to_reg_D,
    input  wire        mem_write_D,
    input  wire [2:0]  alu_ctrl_D,
    input  wire        alu_src_D,
    input  wire        reg_dst_D,
    input  wire        branch_D,
    
    // Outputs to Control Unit (Opcode/Funct from ID stage)
    output wire [31:0] instr_D,
    
    // Outputs for Debugging
    output wire [31:0] pc_out,
    output wire [31:0] alu_result_out
);

    // =====================================================
    // Stage 1: IF (Instruction Fetch)
    // =====================================================
    wire [31:0] pc_F, pc_next_F, pc_plus4_F;
    wire [31:0] instr_F;
    
    // PC Mux Logic (Branching) - handled in MEM stage for now (simplified)
    wire        pc_src_M;
    wire [31:0] pc_branch_M;

    // 实例化 PC 模块
    pc u_pc (
        .clk(clk), 
        .rst_n(rst_n), 
        .pc_next(pc_next_F), 
        .pc(pc_F)
    );

    // 实例化指令存储器
    instruction_memory u_imem (
        .addr(pc_F), 
        .rd(instr_F)
    );

    assign pc_plus4_F = pc_F + 32'd4;
    // 如果 MEM 阶段决定跳转，则使用跳转地址，否则 PC+4
    assign pc_next_F  = (pc_src_M) ? pc_branch_M : pc_plus4_F;

    assign pc_out = pc_F; // Debug Output

    // =====================================================
    // Pipeline Register: IF/ID (Fetch -> Decode)
    // =====================================================
    reg [31:0] instr_D_reg, pc_plus4_D;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_D_reg <= 0;
            pc_plus4_D  <= 0;
        end else begin
            instr_D_reg <= instr_F;
            pc_plus4_D  <= pc_plus4_F;
        end
    end

    assign instr_D = instr_D_reg; // Output to Control Unit

    // =====================================================
    // Stage 2: ID (Decode)
    // =====================================================
    wire [31:0] rd1_D, rd2_D;
    wire [31:0] sign_imm_D;
    wire [31:0] result_W; // Coming from WB stage
    wire [4:0]  write_reg_W;
    wire        reg_write_W;

    reg_file u_reg_file (
        .clk(clk),
        .we3(reg_write_W),      // Write Enable from WB Stage
        .ra1(instr_D[25:21]),   // rs
        .ra2(instr_D[20:16]),   // rt
        .wa3(write_reg_W),      // Write Addr from WB Stage
        .wd3(result_W),         // Write Data from WB Stage
        .rd1(rd1_D),
        .rd2(rd2_D)
    );

    assign sign_imm_D = {{16{instr_D[15]}}, instr_D[15:0]};

    // =====================================================
    // Pipeline Register: ID/EX (Decode -> Execute)
    // =====================================================
    reg       reg_write_E, mem_to_reg_E, mem_write_E, alu_src_E, reg_dst_E, branch_E;
    reg [2:0] alu_ctrl_E;
    reg [31:0] rd1_E, rd2_E, sign_imm_E, pc_plus4_E;
    reg [4:0]  rs_E, rt_E, rd_E;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_E, mem_to_reg_E, mem_write_E, alu_src_E, reg_dst_E, branch_E} <= 0;
            alu_ctrl_E <= 0;
            {rd1_E, rd2_E, sign_imm_E, pc_plus4_E} <= 0;
            {rs_E, rt_E, rd_E} <= 0;
        end else begin
            // Control Signals
            reg_write_E  <= reg_write_D;
            mem_to_reg_E <= mem_to_reg_D;
            mem_write_E  <= mem_write_D;
            alu_ctrl_E   <= alu_ctrl_D;
            alu_src_E    <= alu_src_D;
            reg_dst_E    <= reg_dst_D;
            branch_E     <= branch_D;
            // Data
            rd1_E        <= rd1_D;
            rd2_E        <= rd2_D;
            sign_imm_E   <= sign_imm_D;
            pc_plus4_E   <= pc_plus4_D;
            rs_E         <= instr_D[25:21];
            rt_E         <= instr_D[20:16];
            rd_E         <= instr_D[15:11];
        end
    end

    // =====================================================
    // Stage 3: EX (Execute)
    // =====================================================
    wire [31:0] src_b_E;
    wire [31:0] alu_result_E;
    wire [4:0]  write_reg_E;
    wire [31:0] pc_branch_E;
    wire        zero_E;

    assign src_b_E     = (alu_src_E) ? sign_imm_E : rd2_E;
    assign write_reg_E = (reg_dst_E) ? rd_E : rt_E;
    
    // Branch Target Calc
    assign pc_branch_E = pc_plus4_E + (sign_imm_E << 2);

    alu u_alu (
        .src_a(rd1_E),
        .src_b(src_b_E),
        .alu_ctrl(alu_ctrl_E),
        .result(alu_result_E),
        .zero(zero_E)
    );

    // =====================================================
    // Pipeline Register: EX/MEM (Execute -> Memory)
    // =====================================================
    reg       reg_write_M, mem_to_reg_M, mem_write_M, branch_M, zero_M;
    reg [31:0] alu_result_M, write_data_M, pc_branch_M_reg;
    reg [4:0]  write_reg_M;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_M, mem_to_reg_M, mem_write_M, branch_M, zero_M} <= 0;
            {alu_result_M, write_data_M, pc_branch_M_reg} <= 0;
            write_reg_M <= 0;
        end else begin
            reg_write_M  <= reg_write_E;
            mem_to_reg_M <= mem_to_reg_E;
            mem_write_M  <= mem_write_E;
            branch_M     <= branch_E;
            zero_M       <= zero_E;
            
            alu_result_M <= alu_result_E;
            write_data_M <= rd2_E; // Data to store in memory
            write_reg_M  <= write_reg_E;
            pc_branch_M_reg <= pc_branch_E;
        end
    end

    // =====================================================
    // Stage 4: MEM (Memory)
    // =====================================================
    wire [31:0] read_data_M;

    // Branch Logic (PCSrc)
    assign pc_src_M    = branch_M & zero_M;
    assign pc_branch_M = pc_branch_M_reg; // Feed back to IF stage

    data_memory u_data_mem (
        .clk(clk),
        .mem_write_en(mem_write_M),
        .addr(alu_result_M),
        .write_data(write_data_M),
        .read_data(read_data_M)
    );

    // =====================================================
    // Pipeline Register: MEM/WB (Memory -> Write Back)
    // =====================================================
    reg       reg_write_W_reg, mem_to_reg_W;
    reg [31:0] read_data_W, alu_result_W;
    reg [4:0]  write_reg_W_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_W_reg, mem_to_reg_W} <= 0;
            {read_data_W, alu_result_W} <= 0;
            write_reg_W_reg <= 0;
        end else begin
            reg_write_W_reg <= reg_write_M;
            mem_to_reg_W    <= mem_to_reg_M;
            
            read_data_W     <= read_data_M;
            alu_result_W    <= alu_result_M;
            write_reg_W_reg <= write_reg_M;
        end
    end

    // =====================================================
    // Stage 5: WB (Write Back)
    // =====================================================
    assign result_W    = (mem_to_reg_W) ? read_data_W : alu_result_W;
    assign reg_write_W = reg_write_W_reg; // Feedback to ID stage
    assign write_reg_W = write_reg_W_reg; // Feedback to ID stage
    
    // Debug Output
    assign alu_result_out = result_W; 

endmodule