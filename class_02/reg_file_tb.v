`timescale 1ns / 1ps
module reg_file_tb;
    reg         clk;               // clock
    reg         we3;               // write enable
    reg  [4:0]  ra1, ra2, wa3;     // read/write addresses
    reg  [31:0] wd3;               // write data
    wire [31:0] rd1, rd2;          // read data
    
    reg_file uut (                 // unit under test
        .clk(clk), 
        .we3(we3), 
        .ra1(ra1), .ra2(ra2), .wa3(wa3), 
        .wd3(wd3), 
        .rd1(rd1), .rd2(rd2)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;     // 10ns period
    end
    
    initial begin
        $dumpfile("reg_file.vcd"); // waveform
        $dumpvars(0, reg_file_tb);
    end
    
    initial begin
        // Initialize
        we3 = 0; ra1 = 0; ra2 = 0; wa3 = 0; wd3 = 0;
        #10;
        
        // Test 1: Write to reg 5, read via ra1
        @(negedge clk);
        we3 = 1; wa3 = 5; wd3 = 32'hDEADBEEF;
        @(posedge clk);            // write here
        @(negedge clk);
        we3 = 0;
        ra1 = 5;                   // read port 1
        ra2 = 5;                   // read port 2 (same)
        #1;
        if (rd1 !== 32'hDEADBEEF || rd2 !== 32'hDEADBEEF) 
            $error("Test 1 FAILED");
        else 
            $display("Test 1 PASSED: rd1=%h, rd2=%h", rd1, rd2);
        
        // Test 2: Write to reg 10, read via ra2
        @(negedge clk);
        we3 = 1; wa3 = 10; wd3 = 32'h12345678;
        @(posedge clk);
        @(negedge clk);
        we3 = 0;
        ra1 = 5;                   // still 5
        ra2 = 10;                  // read reg 10
        #1;
        if (rd2 !== 32'h12345678) 
            $error("Test 2 FAILED");
        else 
            $display("Test 2 PASSED: ra2 reads reg10=%h", rd2);
        
        // Test 3: Dual read different registers
        ra1 = 5;                   // DEADBEEF -> CAFEBABE
        ra2 = 10;                  // 12345678
        @(negedge clk);
        we3 = 1; wa3 = 5; wd3 = 32'hCAFEBABE;  // overwrite reg5
        @(posedge clk);
        @(negedge clk);
        we3 = 0;
        #1;
        if (rd1 !== 32'hCAFEBABE || rd2 !== 32'h12345678) 
            $error("Test 3 FAILED");
        else 
            $display("Test 3 PASSED: rd1=%h, rd2=%h", rd1, rd2);
        
        // Test 4: $0 always 0 on both ports
        ra1 = 0;
        ra2 = 0;
        #1;
        if (rd1 !== 32'd0 || rd2 !== 32'd0) 
            $error("Test 4 FAILED");
        else 
            $display("Test 4 PASSED: $0 always 0");
        
        #10;
        $display("=== All Tests Complete ===");
        $finish;
    end
endmodule