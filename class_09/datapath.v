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
    
    // Forwarding Control Signals (Inputs from Forwarding Unit)
    input  wire [1:0]  forward_a_E,
    input  wire [1:0]  forward_b_E,

    // Hazard Detection Signals (Outputs to Forwarding Unit)
    output wire [4:0]  rs_E,
    output wire [4:0]  rt_E,
    output wire [4:0]  write_reg_M,
    output wire        reg_write_M,
    output wire [4:0]  write_reg_W,
    output wire        reg_write_W,
    
    // Other Outputs
    output wire [31:0] instr_D,
    output wire [31:0] pc_out,
    output wire [31:0] alu_result_out
);

    // =====================================================
    // Stage 1: IF (Instruction Fetch)
    // =====================================================
    wire [31:0] pc_F, pc_next_F, pc_plus4_F, instr_F;
    wire        pc_src_M;
    wire [31:0] pc_branch_M;

    // Instantiate PC
    pc u_pc (.clk(clk), .rst_n(rst_n), .pc_next(pc_next_F), .pc(pc_F));
    
    // Instantiate Instruction Memory
    instruction_memory u_imem (.addr(pc_F), .rd(instr_F));

    assign pc_plus4_F = pc_F + 32'd4;
    // Mux for Next PC: Branch Target (from MEM) vs PC+4
    assign pc_next_F  = (pc_src_M) ? pc_branch_M : pc_plus4_F;
    assign pc_out = pc_F;

    // Pipeline Register: IF/ID
    reg [31:0] instr_D_reg, pc_plus4_D;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin instr_D_reg <= 0; pc_plus4_D <= 0; end
        else begin instr_D_reg <= instr_F; pc_plus4_D <= pc_plus4_F; end
    end
    assign instr_D = instr_D_reg;

    // =====================================================
    // Stage 2: ID (Decode)
    // =====================================================
    wire [31:0] rd1_D, rd2_D, sign_imm_D, result_W;
    wire [4:0]  write_reg_W_wire;
    wire        reg_write_W_wire;

    reg_file u_reg_file (
        .clk(~clk), .we3(reg_write_W_wire), 
        .ra1(instr_D[25:21]), .ra2(instr_D[20:16]), 
        .wa3(write_reg_W_wire), .wd3(result_W), 
        .rd1(rd1_D), .rd2(rd2_D)
    );
    assign sign_imm_D = {{16{instr_D[15]}}, instr_D[15:0]}; // Sign Extension

    // Pipeline Register: ID/EX
    reg       reg_write_E_reg, mem_to_reg_E, mem_write_E, alu_src_E, reg_dst_E, branch_E;
    reg [2:0] alu_ctrl_E;
    reg [31:0] rd1_E, rd2_E, sign_imm_E, pc_plus4_E;
    reg [4:0]  rs_E_reg, rt_E_reg, rd_E;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_E_reg, mem_to_reg_E, mem_write_E, alu_src_E, reg_dst_E, branch_E} <= 0;
            alu_ctrl_E <= 0; {rd1_E, rd2_E, sign_imm_E, pc_plus4_E} <= 0; {rs_E_reg, rt_E_reg, rd_E} <= 0;
        end else begin
            // Control Signals
            reg_write_E_reg <= reg_write_D; mem_to_reg_E <= mem_to_reg_D; mem_write_E <= mem_write_D;
            alu_ctrl_E <= alu_ctrl_D; alu_src_E <= alu_src_D; reg_dst_E <= reg_dst_D; branch_E <= branch_D;
            // Data
            rd1_E <= rd1_D; rd2_E <= rd2_D; sign_imm_E <= sign_imm_D; pc_plus4_E <= pc_plus4_D;
            rs_E_reg <= instr_D[25:21]; rt_E_reg <= instr_D[20:16]; rd_E <= instr_D[15:11];
        end
    end

    // Output Registers to Forwarding Unit
    assign rs_E = rs_E_reg;
    assign rt_E = rt_E_reg;

    // =====================================================
    // Stage 3: EX (Execute) - Now with Forwarding Muxes
    // =====================================================
    wire [31:0] src_a_E_final, src_b_E_temp, src_b_E_final;
    wire [31:0] alu_result_E, alu_result_M_wire;
    wire [4:0]  write_reg_E;
    wire        zero_E;

    // --- MUX A for Forwarding ---
    // 00: ID/EX (Normal), 10: EX/MEM (Forward), 01: MEM/WB (Forward)
    assign src_a_E_final = (forward_a_E == 2'b10) ? alu_result_M_wire :
                           (forward_a_E == 2'b01) ? result_W : rd1_E;

    // --- MUX B for Forwarding ---
    // Intermediate result before ALUSrc Mux
    assign src_b_E_temp  = (forward_b_E == 2'b10) ? alu_result_M_wire :
                           (forward_b_E == 2'b01) ? result_W : rd2_E;

    // Standard ALUSrc Mux (Select between Reg B and Immediate)
    assign src_b_E_final = (alu_src_E) ? sign_imm_E : src_b_E_temp;

    // Write Register Mux (Rt vs Rd)
    assign write_reg_E = (reg_dst_E) ? rd_E : rt_E;
    
    alu u_alu (
        .src_a(src_a_E_final), .src_b(src_b_E_final), 
        .alu_ctrl(alu_ctrl_E), .result(alu_result_E), .zero(zero_E)
    );

    // Pipeline Register: EX/MEM
    reg       reg_write_M_reg, mem_to_reg_M, mem_write_M, branch_M, zero_M;
    reg [31:0] alu_result_M_reg, write_data_M, pc_branch_M_reg;
    reg [4:0]  write_reg_M_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_M_reg, mem_to_reg_M, mem_write_M, branch_M, zero_M} <= 0;
            {alu_result_M_reg, write_data_M, pc_branch_M_reg} <= 0; write_reg_M_reg <= 0;
        end else begin
            reg_write_M_reg <= reg_write_E_reg; mem_to_reg_M <= mem_to_reg_E; mem_write_M <= mem_write_E;
            branch_M <= branch_E; zero_M <= zero_E;
            alu_result_M_reg <= alu_result_E; 
            write_data_M <= src_b_E_temp; // Important: Store the correct (forwarded) data!
            write_reg_M_reg <= write_reg_E; 
            pc_branch_M_reg <= pc_plus4_E + (sign_imm_E << 2);
        end
    end

    // Outputs for Forwarding Unit & Internal wiring
    assign alu_result_M_wire = alu_result_M_reg;
    assign write_reg_M = write_reg_M_reg;
    assign reg_write_M = reg_write_M_reg;

    // =====================================================
    // Stage 4: MEM (Memory Access)
    // =====================================================
    wire [31:0] read_data_M;
    assign pc_src_M    = branch_M & zero_M; // AND gate for Branch
    assign pc_branch_M = pc_branch_M_reg;

    data_memory u_data_mem (
        .clk(clk), .mem_write_en(mem_write_M), 
        .addr(alu_result_M_reg), .write_data(write_data_M), 
        .read_data(read_data_M)
    );

    // Pipeline Register: MEM/WB
    reg       reg_write_W_reg, mem_to_reg_W;
    reg [31:0] read_data_W, alu_result_W;
    reg [4:0]  write_reg_W_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            {reg_write_W_reg, mem_to_reg_W} <= 0; {read_data_W, alu_result_W} <= 0; write_reg_W_reg <= 0;
        end else begin
            reg_write_W_reg <= reg_write_M_reg; mem_to_reg_W <= mem_to_reg_M;
            read_data_W <= read_data_M; alu_result_W <= alu_result_M_reg; write_reg_W_reg <= write_reg_M_reg;
        end
    end

    // Outputs for Forwarding Unit & WB Logic
    assign write_reg_W = write_reg_W_reg;
    assign reg_write_W = reg_write_W_reg;
    
    // =====================================================
    // Stage 5: WB (Write Back)
    // =====================================================
    // Mux for Write Back Data (Memory vs ALU Result)
    assign result_W = (mem_to_reg_W) ? read_data_W : alu_result_W;
    
    // Connect to RegFile Inputs
    assign reg_write_W_wire = reg_write_W_reg;
    assign write_reg_W_wire = write_reg_W_reg;

    assign alu_result_out = result_W;

endmodule