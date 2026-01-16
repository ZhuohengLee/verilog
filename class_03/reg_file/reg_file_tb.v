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
        @(negedge clk); // Wait for write to complete (non-blocking)
        we3 = 0;
        
        ra1 = 5;
        #1;
        if (rd1 !== 32'hDEADBEEF) $error("Write Failed: Expected DEADBEEF, got %h", rd1);
        else $display("Write/Read Passed");

        // Test 2: Verify second write works correctly
        // Write new value to Reg 5
        @(negedge clk);
        ra1 = 5;       // Currently DEADBEEF
        wa3 = 5;       // Writing to 5
        wd3 = 32'hCAFEBABE; 
        we3 = 1;

        @(posedge clk); // Clock edge - write happens
        @(negedge clk); // Wait for write to complete
        we3 = 0;
        
        #1;
        if (rd1 !== 32'hCAFEBABE) $error("Second Write Failed: Expected CAFEBABE, got %h", rd1);
        else $display("Second Write Passed");

        // Test 3: Verify $0 always reads 0
        ra1 = 0;
        #1;
        if (rd1 !== 32'd0) $error("$0 Read Failed: Expected 0");
        else $display("$0 Always Zero Passed");

        #10;
        $finish;
    end
endmodule
