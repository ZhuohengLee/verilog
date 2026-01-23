`timescale 1ns / 1ps
module mips_tb;
    reg         clk, rst_n;
    reg  [7:0]  switches;     
    wire [7:0]  leds;         
    wire [31:0] pc_out, alu_result;
    mips uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .switches(switches), 
        .leds(leds), 
        .pc_out(pc_out), 
        .alu_result(alu_result)
    );
    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end
    initial begin 
        $dumpfile("recursive.vcd"); 
        $dumpvars(0, mips_tb); 
    end
    initial begin
        rst_n = 0; 
        switches = 8'h00;  
        #10; 
        rst_n = 1;
        $display("===========================================");
        $display("   Week 13: MIPS CPU Final PBL Demo       ");
        $display("===========================================");
        $display("");
        $display("[Phase 1] Running Recursive Sum(5)...");
        $display("         Switch Input: %d", switches);
        repeat (150) @(posedge clk);
        switches = 8'h05;  
        $display("");
        $display("[Phase 2] Switches changed to: %d", switches);
        repeat (50) @(posedge clk);
        switches = 8'hAA;  
        $display("[Phase 3] Switches changed to: 0x%h (%b)", switches, switches);
        repeat (50) @(posedge clk);
        switches = 8'hFF;  
        $display("[Phase 4] Switches changed to: 0x%h (all ON)", switches);
        repeat (50) @(posedge clk);
        $display("");
        $display("===========================================");
        $display("   Final Results                          ");
        $display("===========================================");
        $display("   LED Output: %d (0x%h)", leds, leds);
        $display("   Switch Input: %d (0x%h)", switches, switches);
        if (leds == 8'h0F) 
            $display("   Status: SUCCESS - Recursive Sum = 15");
        else 
            $display("   Status: LED = %d", leds);
        $display("===========================================");
        $finish;
    end
    always @(leds) begin
        if (rst_n)
            $display("   [Monitor] LED changed to: %d (0x%h) at time %0t", 
                     leds, leds, $time);
    end
endmodule