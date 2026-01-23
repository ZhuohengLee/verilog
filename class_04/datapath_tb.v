`timescale 1ns / 1ps
module datapath_tb;
    reg clk;
    reg rst_n;
    reg reg_write_en;
    reg reg_dst;
    reg alu_src;
    reg [2:0] alu_ctrl;
    reg mem_write_en;
    reg mem_to_reg;
    wire [31:0] pc_out;
    wire [31:0] alu_result;
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
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
        $dumpfile("datapath.vcd");
        $dumpvars(0, datapath_tb);
    end
    initial begin
        rst_n = 0;
        reg_write_en = 0; reg_dst = 0; alu_src = 0; 
        alu_ctrl = 0; mem_write_en = 0; mem_to_reg = 0;
        #10;
        rst_n = 1;
        $display("--- Start Simulation ---");
        reg_write_en = 1; alu_src = 1; alu_ctrl = 3'b010; reg_dst = 0; mem_write_en = 0;
        #2; 
        $display("PC: %h | Result: %d (Expected 5)", pc_out, alu_result);
        @(posedge clk); 
        #1; 
        reg_write_en = 1; alu_src = 1; alu_ctrl = 3'b010; reg_dst = 0; mem_write_en = 0;
        #2;
        $display("PC: %h | Result: %d (Expected 10)", pc_out, alu_result);
        @(posedge clk); 
        #1;
        reg_write_en = 1; alu_src = 0; alu_ctrl = 3'b010; reg_dst = 1; mem_write_en = 0;
        #2;
        $display("PC: %h | Result: %d (Expected 15)", pc_out, alu_result);
        @(posedge clk); 
        #1;
        reg_write_en = 0; alu_src = 1; alu_ctrl = 3'b010; mem_write_en = 1;
        #2;
        $display("PC: %h | Store Addr: %d (Expected 4)", pc_out, alu_result);
        @(posedge clk); 
        #20;
        $finish;
    end
endmodule