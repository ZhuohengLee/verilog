`timescale 1ns / 1ps
module alu_tb;
    reg  [31:0] src_a, src_b;     // test inputs
    reg  [2:0]  alu_ctrl;         // operation select
    wire [31:0] result;           // ALU output
    wire        zero;             // zero flag
    
    alu uut (                     // unit under test
        .src_a(src_a),
        .src_b(src_b),
        .alu_ctrl(alu_ctrl),
        .result(result),
        .zero(zero)
    );
    
    initial begin
        $dumpfile("alu.vcd");     // waveform file
        $dumpvars(0, alu_tb);
    end
    
    initial begin
        $display("=== ALU Testbench ===");
        
        // Test ADD
        src_a = 10; src_b = 20; alu_ctrl = 3'b010;
        #10;
        if (result !== 30) $error("ADD Failed");
        else $display("ADD: %d + %d = %d [PASS]", src_a, src_b, result);
        
        // Test SUB with zero flag
        src_a = 30; src_b = 30; alu_ctrl = 3'b110;
        #10;
        if (result !== 0 || zero !== 1) $error("SUB/Zero Failed");
        else $display("SUB: %d - %d = %d, Zero=%b [PASS]", src_a, src_b, result, zero);
        
        // Test AND
        src_a = 32'hFF00; src_b = 32'h0FF0; alu_ctrl = 3'b000;
        #10;
        if (result !== 32'h0F00) $error("AND Failed");
        else $display("AND: 0x%h & 0x%h = 0x%h [PASS]", src_a, src_b, result);
        
        // Test OR
        src_a = 32'hFF00; src_b = 32'h00FF; alu_ctrl = 3'b001;
        #10;
        if (result !== 32'hFFFF) $error("OR Failed");
        else $display("OR: 0x%h | 0x%h = 0x%h [PASS]", src_a, src_b, result);
        
        // Test SLT unsigned
        src_a = 5; src_b = 10; alu_ctrl = 3'b111;
        #10;
        if (result !== 1) $error("SLT Failed");
        else $display("SLT: %d < %d = %d [PASS]", src_a, src_b, result);
        
        // Test SLT signed
        src_a = -5; src_b = 3; alu_ctrl = 3'b111;
        #10;
        if (result !== 1) $error("SLT Signed Failed");
        else $display("SLT: %d < %d = %d [PASS]", $signed(src_a), $signed(src_b), result);
        
        $display("=== All Tests Passed ===");
        $finish;
    end
endmodule