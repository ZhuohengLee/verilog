`timescale 1ns / 1ps

module alu_tb;

    // Signals
    reg  [31:0] src_a, src_b;
    reg  [2:0]  alu_ctrl;
    wire [31:0] result;
    wire        zero;

    // Instantiate Unit Under Test (UUT)
    alu uut (
        .src_a(src_a), 
        .src_b(src_b), 
        .alu_ctrl(alu_ctrl), 
        .result(result), 
        .zero(zero)
    );

    // GTKWave Setup
    initial begin
        $dumpfile("alu.vcd");
        $dumpvars(0, alu_tb);
    end

    // Test Stimulus
    initial begin
        // Test 1: ADD (10 + 20)
        src_a = 10; src_b = 20; alu_ctrl = 3'b010;
        #10;
        if (result !== 30) $error("ADD Failed: 10+20=%d", result);
        else $display("ADD Passed");

        // Test 2: SUB (30 - 30) & Zero Flag
        src_a = 30; src_b = 30; alu_ctrl = 3'b110;
        #10;
        if (result !== 0 || zero !== 1) $error("SUB/Zero Failed");
        else $display("SUB/Zero Passed");

        // Test 3: SLT Signed (-5 < 10)
        src_a = -5; src_b = 10; alu_ctrl = 3'b111;
        #10;
        if (result !== 1) $error("SLT Failed: -5 < 10 returned %d", result);
        else $display("SLT Passed");

        #10;
        $finish;
    end
endmodule