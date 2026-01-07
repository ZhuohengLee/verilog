`timescale 1ns / 1ps

module counter_tb;

    // 1. Signal Declaration
    reg clk;
    reg reset;
    wire [3:0] count;

    // 2. Instantiate the Unit Under Test (UUT)
    counter uut (
        .clk(clk),
        .reset(reset),
        .count(count)
    );

    // 3. Clock Generation (100MHz)
    always begin
        #5 clk = ~clk;
    end

    // 4. Test Logic and Waveform Dump
    initial begin
        // --- Setup for Icarus Verilog + GTKWave ---
        $dumpfile("counter_test.vcd"); // Specify the output waveform filename
        $dumpvars(0, counter_tb);      // Dump all variables in counter_tb and sub-modules

        // Initialize signals
        clk = 0;
        reset = 0;

        // --- Simulation Actions ---
        #10 reset = 1;        // At 10ns: Assert asynchronous reset
        #15 reset = 0;        // At 25ns: De-assert (release) reset, start counting

        #200;                 // Run for 200ns, observe counter counting and overflow

        #10 reset = 1;        // Test reset functionality again
        #10 reset = 0;

        #50;
        $display("Simulation complete. Please open counter_test.vcd with GTKWave to view waveforms. Good luck!");
        $finish;              // End simulation
    end

    // Monitor: Real-time console output (Optional)
    initial begin
        $monitor("Time: %0t | Reset: %b | Count: %d", $time, reset, count);
    end

endmodule