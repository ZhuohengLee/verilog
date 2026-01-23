`timescale 1ns / 1ps
module datapath (
    input  wire        clk,
    input  wire        rst_n,
    // Control signals from Control Unit (generated in Decode stage)
    input  wire        reg_write_D,
    input  wire        mem_to_reg_D,
    input  wire        mem_write_D,
    input  wire [2:0]  alu_ctrl_D,
    input  wire        alu_src_D,
    input  wire        reg_dst_D,
    input  wire        branch_D,
    // Outputs
    output wire [31:0] instr_D,         // Instruction to control unit
    output wire [31:0] pc_out,          // Current PC for debug
    output wire [31:0] alu_result_out   // Final result for debug
);

    //==========================================================================
    // Stage 1: FETCH (F)
    //==========================================================================
    wire [31:0] pc_F, pc_next_F, pc_plus4_F;
    wire [31:0] instr_F;
    wire        pc_src_M;           // Branch decision from MEM stage
    wire [31:0] pc_branch_M;        // Branch target from MEM stage

    // Program Counter
    pc u_pc (
        .clk(clk),
        .rst_n(rst_n),
        .pc_next(pc_next_F),
        .pc(pc_F)
    );

    // Instruction Memory
    instruction_memory u_imem (
        .addr(pc_F),
        .rd(instr_F)
    );

    // Next PC calculation
    assign pc_plus4_F = pc_F + 32'd4;
    assign pc_next_F  = (pc_src_M) ? pc_branch_M : pc_plus4_F;
    assign pc_out = pc_F;

    //==========================================================================
    // Pipeline Register: IF/ID
    //==========================================================================
    reg [31:0] instr_D_reg, pc_plus4_D;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instr_D_reg <= 32'b0;
            pc_plus4_D  <= 32'b0;
        end else begin
            instr_D_reg <= instr_F;
            pc_plus4_D  <= pc_plus4_F;
        end
    end
    assign instr_D = instr_D_reg;

    //==========================================================================
    // Stage 2: DECODE (D)
    //==========================================================================
    wire [31:0] rd1_D, rd2_D;
    wire [31:0] sign_imm_D;

    // These come from Write-back stage
    wire [31:0] result_W;
    wire [4:0]  write_reg_W;
    wire        reg_write_W;

    // Register File
    reg_file u_reg_file (
        .clk(clk),
        .we3(reg_write_W),
        .ra1(instr_D[25:21]),       // rs
        .ra2(instr_D[20:16]),       // rt
        .wa3(write_reg_W),
        .wd3(result_W),
        .rd1(rd1_D),
        .rd2(rd2_D)
    );

    // Sign Extension
    assign sign_imm_D = {{16{instr_D[15]}}, instr_D[15:0]};

    //==========================================================================
    // Pipeline Register: ID/EX
    //==========================================================================
    reg        reg_write_E, mem_to_reg_E, mem_write_E;
    reg        alu_src_E, reg_dst_E, branch_E;
    reg [2:0]  alu_ctrl_E;
    reg [31:0] rd1_E, rd2_E, sign_imm_E, pc_plus4_E;
    reg [4:0]  rs_E, rt_E, rd_E;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_E, mem_to_reg_E, mem_write_E, alu_src_E, reg_dst_E, branch_E} <= 6'b0;
            alu_ctrl_E <= 3'b0;
            {rd1_E, rd2_E, sign_imm_E, pc_plus4_E} <= 128'b0;
            {rs_E, rt_E, rd_E} <= 15'b0;
        end else begin
            // Control signals propagation
            reg_write_E  <= reg_write_D;
            mem_to_reg_E <= mem_to_reg_D;
            mem_write_E  <= mem_write_D;
            alu_ctrl_E   <= alu_ctrl_D;
            alu_src_E    <= alu_src_D;
            reg_dst_E    <= reg_dst_D;
            branch_E     <= branch_D;
            // Data signals propagation
            rd1_E        <= rd1_D;
            rd2_E        <= rd2_D;
            sign_imm_E   <= sign_imm_D;
            pc_plus4_E   <= pc_plus4_D;
            // Register addresses for forwarding (Week 8)
            rs_E         <= instr_D[25:21];
            rt_E         <= instr_D[20:16];
            rd_E         <= instr_D[15:11];
        end
    end

    //==========================================================================
    // Stage 3: EXECUTE (E)
    //==========================================================================
    wire [31:0] src_b_E;
    wire [31:0] alu_result_E;
    wire [4:0]  write_reg_E;
    wire [31:0] pc_branch_E;
    wire        zero_E;

    // ALU Source MUX
    assign src_b_E = (alu_src_E) ? sign_imm_E : rd2_E;

    // Write Register MUX (rd or rt)
    assign write_reg_E = (reg_dst_E) ? rd_E : rt_E;

    // Branch Target Calculation
    assign pc_branch_E = pc_plus4_E + (sign_imm_E << 2);

    // ALU
    alu u_alu (
        .src_a(rd1_E),
        .src_b(src_b_E),
        .alu_ctrl(alu_ctrl_E),
        .result(alu_result_E),
        .zero(zero_E)
    );

    //==========================================================================
    // Pipeline Register: EX/MEM
    //==========================================================================
    reg        reg_write_M, mem_to_reg_M, mem_write_M, branch_M, zero_M;
    reg [31:0] alu_result_M, write_data_M, pc_branch_M_reg;
    reg [4:0]  write_reg_M;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_M, mem_to_reg_M, mem_write_M, branch_M, zero_M} <= 5'b0;
            {alu_result_M, write_data_M, pc_branch_M_reg} <= 96'b0;
            write_reg_M <= 5'b0;
        end else begin
            reg_write_M     <= reg_write_E;
            mem_to_reg_M    <= mem_to_reg_E;
            mem_write_M     <= mem_write_E;
            branch_M        <= branch_E;
            zero_M          <= zero_E;
            alu_result_M    <= alu_result_E;
            write_data_M    <= rd2_E;
            write_reg_M     <= write_reg_E;
            pc_branch_M_reg <= pc_branch_E;
        end
    end

    //==========================================================================
    // Stage 4: MEMORY (M)
    //==========================================================================
    wire [31:0] read_data_M;

    // Branch decision
    assign pc_src_M    = branch_M & zero_M;
    assign pc_branch_M = pc_branch_M_reg;

    // Data Memory
    data_memory u_data_mem (
        .clk(clk),
        .mem_write_en(mem_write_M),
        .addr(alu_result_M),
        .write_data(write_data_M),
        .read_data(read_data_M)
    );

    //==========================================================================
    // Pipeline Register: MEM/WB
    //==========================================================================
    reg        reg_write_W_reg, mem_to_reg_W;
    reg [31:0] read_data_W, alu_result_W;
    reg [4:0]  write_reg_W_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_W_reg, mem_to_reg_W} <= 2'b0;
            {read_data_W, alu_result_W} <= 64'b0;
            write_reg_W_reg <= 5'b0;
        end else begin
            reg_write_W_reg <= reg_write_M;
            mem_to_reg_W    <= mem_to_reg_M;
            read_data_W     <= read_data_M;
            alu_result_W    <= alu_result_M;
            write_reg_W_reg <= write_reg_M;
        end
    end

    //==========================================================================
    // Stage 5: WRITE-BACK (W)
    //==========================================================================
    // Write-back MUX
    assign result_W    = (mem_to_reg_W) ? read_data_W : alu_result_W;
    assign reg_write_W = reg_write_W_reg;
    assign write_reg_W = write_reg_W_reg;

    // Debug output
    assign alu_result_out = result_W;

endmodule