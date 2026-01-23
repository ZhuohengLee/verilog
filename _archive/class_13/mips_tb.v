`timescale 1ns / 1ps
module mips_tb;
    reg clk, rst_n;
    reg [7:0] switches;
    wire [7:0] leds;
    wire [31:0] pc_out, alu_result;

    mips uut (
        .clk(clk), .rst_n(rst_n), 
        .switches(switches), .leds(leds), 
        .pc_out(pc_out), .alu_result(alu_result)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin $dumpfile("recursive.vcd"); $dumpvars(0, mips_tb); end

    initial begin
        rst_n = 0; switches = 0;
        #10; rst_n = 1;
        $display("--- Recursive Sum(5) Simulation Start ---");
        
        // Run for enough time to complete the recursion (300 clock cycles)
        repeat (300) @(posedge clk);
        
        // Check if the result is 15 (0x0F)
        if (leds == 8'h0F) 
            $display("SUCCESS: Sum(5) = 15 (0x0F). Recursion Works!");
        else 
            $display("FAIL: Expected 15 (0x0F), Got %d (0x%h)", leds, leds);
            
        $finish;
    end
endmodule