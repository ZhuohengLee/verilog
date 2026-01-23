`timescale 1ns / 1ps
module mips_tb;
    reg clk, rst_n;
    reg [7:0] switches;
    wire [7:0] leds;
    wire [31:0] pc_out, alu_result;
    wire [31:0] total_cycles, stall_cycles, flush_cycles;

    mips uut (
        .clk(clk), .rst_n(rst_n), 
        .switches(switches), .leds(leds), 
        .pc_out(pc_out), .alu_result(alu_result),
        .total_cycles(total_cycles),
        .stall_cycles(stall_cycles),
        .flush_cycles(flush_cycles)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin $dumpfile("led_counter.vcd"); $dumpvars(0, mips_tb); end

    initial begin
        rst_n = 0; switches = 0;
        #10; rst_n = 1;
        $display("==============================================");
        $display("   Interactive LED Counter Demo - Week 15");
        $display("==============================================");
        $display("");
        $display("Time(ns) | Switches | LEDs     | Accumulator");
        $display("----------------------------------------------");
        
        // Test 1: switches = 1, should count up by 1 each iteration
        switches = 8'h01;
        repeat (500) @(posedge clk);
        $display("%8t |    0x%02h  |   0x%02h   | %d", $time, switches, leds, leds);
        
        // Test 2: switches = 5, should count up by 5
        switches = 8'h05;
        repeat (500) @(posedge clk);
        $display("%8t |    0x%02h  |   0x%02h   | %d", $time, switches, leds, leds);
        
        // Test 3: switches = 10, should count up by 10
        switches = 8'h0A;
        repeat (500) @(posedge clk);
        $display("%8t |    0x%02h  |   0x%02h   | %d", $time, switches, leds, leds);
        
        // Test 4: switches = 0, should stop counting
        switches = 8'h00;
        repeat (500) @(posedge clk);
        $display("%8t |    0x%02h  |   0x%02h   | %d", $time, switches, leds, leds);
        
        // Test 5: switches = 3, resume counting
        switches = 8'h03;
        repeat (500) @(posedge clk);
        $display("%8t |    0x%02h  |   0x%02h   | %d", $time, switches, leds, leds);
        
        $display("----------------------------------------------");
        $display("");
        $display("--- Performance Metrics ---");
        $display("Total Cycles: %d", total_cycles);
        $display("Stall Cycles: %d", stall_cycles);
        $display("");
        $display("Demo completed successfully!");
        $finish;
    end
endmodule