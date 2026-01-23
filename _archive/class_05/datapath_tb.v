`timescale 1ns / 1ps

module datapath_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg reg_write_en;
    reg reg_dst;
    reg alu_src;
    reg [2:0] alu_ctrl;
    reg mem_write_en;
    reg mem_to_reg;

    // Outputs
    wire [31:0] pc_out;
    wire [31:0] alu_result;

    // Instantiate UUT
    datapath uut (
        .clk(clk),
        .rst_n(rst_n),
        .reg_write_en(reg_write_en),
        .reg_dst(reg_dst),
        .alu_src(alu_src),
        .alu_ctrl(alu_ctrl),
        .mem_write_en(mem_write_en),
        .mem_to_reg(mem_to_reg),
        .pc_out(pc_out),
        .alu_result(alu_result)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // GTKWave
    initial begin
        $dumpfile("datapath.vcd");
        $dumpvars(0, datapath_tb);
    end

    // Test Sequence
    initial begin
        // Init
        rst_n = 0;
        reg_write_en = 0; reg_dst = 0; alu_src = 0; 
        alu_ctrl = 0; mem_write_en = 0; mem_to_reg = 0;
        #10;
        
        rst_n = 1;
        $display("--- Start Simulation ---");

        // ======================================================
        // Cycle 1: PC=0 -> instr: addi $t0, $0, 5
        // ======================================================
        // 1. 设置信号
        reg_write_en = 1; alu_src = 1; alu_ctrl = 3'b010; reg_dst = 0; mem_write_en = 0;
        // 2. 等待组合逻辑稳定 (在时钟上升沿到来之前！)
        #2; 
        // 3. 检查结果
        $display("PC: %h | Result: %d (Expected 5)", pc_out, alu_result);
        // 4. 等待时钟上升沿 (Commit: 写入寄存器, PC -> 4)
        @(posedge clk); 

        // ======================================================
        // Cycle 2: PC=4 -> instr: addi $t1, $0, 10
        // ======================================================
        #1; // 给一点 hold time
        reg_write_en = 1; alu_src = 1; alu_ctrl = 3'b010; reg_dst = 0; mem_write_en = 0;
        #2;
        $display("PC: %h | Result: %d (Expected 10)", pc_out, alu_result);
        @(posedge clk); 

        // ======================================================
        // Cycle 3: PC=8 -> instr: add $t2, $t0, $t1
        // ======================================================
        #1;
        reg_write_en = 1; alu_src = 0; alu_ctrl = 3'b010; reg_dst = 1; mem_write_en = 0;
        #2;
        $display("PC: %h | Result: %d (Expected 15)", pc_out, alu_result);
        @(posedge clk); 

        // ======================================================
        // Cycle 4: PC=12 -> instr: sw $t2, 4($0)
        // ======================================================
        #1;
        reg_write_en = 0; alu_src = 1; alu_ctrl = 3'b010; mem_write_en = 1;
        #2;
        $display("PC: %h | Store Addr: %d (Expected 4)", pc_out, alu_result);
        @(posedge clk); 

        #20;
        $finish;
    end

endmodule