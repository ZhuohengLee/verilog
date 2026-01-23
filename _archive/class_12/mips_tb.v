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
    initial begin $dumpfile("io.vcd"); $dumpvars(0, mips_tb); end

    initial begin
        rst_n = 0; switches = 0;
        #10; rst_n = 1;
        $display("--- MMIO GPIO Simulation Start ---");
        

        #50; 
        switches = 8'hAA;
        $display("Time: %0t | Switch Changed to: %h", $time, switches);
        

        #100;
        if (leds == 8'hAA) $display("Time: %0t | LED Updated: %h (SUCCESS)", $time, leds);
        else               $display("Time: %0t | LED Updated: %h (FAIL - Expected AA)", $time, leds);


        #50;
        switches = 8'h55;
        $display("Time: %0t | Switch Changed to: %h", $time, switches);
        
        #100;
        if (leds == 8'h55) $display("Time: %0t | LED Updated: %h (SUCCESS)", $time, leds);
        else               $display("Time: %0t | LED Updated: %h (FAIL - Expected 55)", $time, leds);

        $finish;
    end
endmodule