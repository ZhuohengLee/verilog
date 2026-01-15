`timescale 1ns / 1ps

module mips_tb;
    reg clk;
    reg rst_n;
    wire [31:0] pc_out;
    wire [31:0] alu_result;

    // Instantiate Top Level CPU
    mips uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .pc_out(pc_out), 
        .alu_result(alu_result)
    );

    // Clock Generation
    initial begin 
        clk = 0; 
        forever #5 clk = ~clk; 
    end

    // GTKWave Configuration
    initial begin 
        $dumpfile("forwarding.vcd"); 
        $dumpvars(0, mips_tb); 
    end

    // Test Sequence
    initial begin
        rst_n = 0; 
        #10; 
        rst_n = 1;
        $display("--- Forwarding Unit Simulation Start ---");
        
        repeat (20) begin
            @(negedge clk);
            // Only display valid results (filter out NOPs/Init zeros)
            if (alu_result !== 0) 
                $display("Time: %0t | PC: %h | WB Result: %d", $time, pc_out, alu_result);
            @(posedge clk);
        end
        $finish;
    end
endmodule