`timescale 1ns / 1ps

module reg_file_tb;

    // Signals
    reg         clk;
    reg         we3;
    reg  [4:0]  ra1, ra2, wa3;
    reg  [31:0] wd3;
    wire [31:0] rd1, rd2;

    // Instantiate UUT
    reg_file uut (
        .clk(clk), .we3(we3), 
        .ra1(ra1), .ra2(ra2), .wa3(wa3), 
        .wd3(wd3), .rd1(rd1), .rd2(rd2)
    );

    // Clock Generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // GTKWave Setup
    initial begin
        $dumpfile("reg_file.vcd");
        $dumpvars(0, reg_file_tb);
    end

    // Test Stimulus
    initial begin
        // Init
        we3 = 0; ra1 = 0; ra2 = 0; wa3 = 0; wd3 = 0;
        #10;

        // Test 1: Write Reg 5, Read Reg 5
        @(negedge clk);
        we3 = 1; wa3 = 5; wd3 = 32'hDEADBEEF;
        @(posedge clk); // Write happens here
        we3 = 0;
        
        #2; // Wait a bit
        ra1 = 5;
        #5;
        if (rd1 !== 32'hDEADBEEF) $error("Write Failed: Expected DEADBEEF");
        else $display("Write/Read Passed");

        // Test 2: Read Old Value (RAW)
        // Write new value to Reg 5 while reading it
        @(negedge clk);
        ra1 = 5;       // Currently DEADBEEF
        wa3 = 5;       // Writing to 5
        wd3 = 32'hCAFEBABE; // New Value
        we3 = 1;

        @(posedge clk); // Clock edge!
        #1; // Just after edge
        
        if (rd1 !== 32'hDEADBEEF) $error("RAW Failed: Should read OLD value immediately after edge");
        else $display("RAW Policy Passed (Read Old Value)");

        #10;
        $finish;
    end
endmodule