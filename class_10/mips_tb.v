`timescale 1ns / 1ps
module mips_tb;
    reg         clk;               // clock
    reg         rst_n;             // reset
    wire [31:0] pc_out;            // PC value
    wire [31:0] alu_result;        // ALU output
    
    mips uut (                     // unit under test
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out),
        .alu_result(alu_result)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;     // 10ns period
    end
    
    initial begin
        $dumpfile("mips.vcd");     // waveform
        $dumpvars(0, mips_tb);
    end
    
    initial begin
        rst_n = 0;                 // apply reset
        #10;
        rst_n = 1;                 // release reset
        
        $display("===========================================");
        $display("   MIPS Single Cycle Simulation Start    ");
        $display("===========================================");
        
        repeat (15) begin
            @(negedge clk);        // wait for clock
            #1;
            $display("PC: 0x%h | ALU Result: %d", pc_out, alu_result);
        end
        
        $display("===========================================");
        $display("   Simulation Complete                   ");
        $display("===========================================");
        $finish;
    end
endmodule