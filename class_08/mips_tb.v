`timescale 1ns / 1ps

module mips_tb;

    reg         clk;
    reg         rst_n;
    wire [31:0] pc_out;
    wire [31:0] alu_result;

    mips uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out),
        .alu_result(alu_result)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, mips_tb);
    end

    initial begin
        rst_n = 0;
        #10;
        rst_n = 1;
        $display("--- Pipelined CPU Simulation Start ---");
        
        repeat (30) begin
            @(negedge clk);
            // 只有当 ALU 有有效结果时才打印 (简单过滤掉 NOP 产生的 0)
            if (alu_result !== 0)
                $display("Time: %0t | PC (Fetch): %h | WB Result: %d", $time, pc_out, alu_result);
            @(posedge clk);
        end
        $finish;
    end
endmodule