`timescale 1ns / 1ps

module mips_tb;

    reg         clk;
    reg         rst_n;
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

    // GTKWave Setup
    initial begin
        $dumpfile("mips_fib.vcd");
    end

    // Test Sequence
    initial begin
        rst_n = 0;
        #10;
        rst_n = 1;
        $display("--- Fibonacci Simulation Start ---");

        // Run for 50 cycles to observe sequence generation
        repeat (50) begin
            @(negedge clk); // Check results on the falling edge (data is stable)
            
            // For easier observation, only print the calculation line (PC=8)
            if (pc_out == 32'h8) 
                $display("Time: %0t | Fibonacci Number: %d", $time, alu_result);
            else if (pc_out == 32'h14)
                $display("Time: %0t | Looping back...", $time);
                
            @(posedge clk);
        end

        $finish;
    end

endmodule