`timescale 1ns / 1ps

module shift_register_tb;

    // 1. Parameters
    parameter WIDTH = 32;
    parameter CLK_PERIOD = 10; // 10ns clock period

    // 2. Test Signals
    reg              clk;
    reg              rst_n;
    reg  [1:0]       ctrl;
    reg  [WIDTH-1:0] d_in;
    reg              serial_in_left;
    reg              serial_in_right;
    wire [WIDTH-1:0] q_out;

    // 3. Instantiate the Unit Under Test (UUT)
    shift_register #(.WIDTH(WIDTH)) uut (
        .clk(clk), 
        .rst_n(rst_n), 
        .ctrl(ctrl), 
        .d_in(d_in), 
        .serial_in_left(serial_in_left), 
        .serial_in_right(serial_in_right), 
        .q_out(q_out)
    );

    // 4. Clock Generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ==========================================
    // 5. GTKWave Setup (Added for Waveform)
    // ==========================================
    initial begin
        // Specify the output waveform filename (Must match Makefile VCD variable)
        $dumpfile("shift_register.vcd");

        // Dump all signals in this module and sub-modules
        $dumpvars(0, shift_register_tb);
    end

    // 6. Test Stimulus
    initial begin
        // Initialize Inputs
        rst_n = 0;
        ctrl = 2'b00;
        d_in = 0;
        serial_in_left = 0;
        serial_in_right = 0;

        // Apply Reset
        #20 rst_n = 1;
        $display("--- Reset Released ---");

        // Test Case 1: Parallel Load
        // Load pattern 0xAAAAAAAA (1010...)
        #10;
        ctrl = 2'b11; 
        d_in = 32'hAAAAAAAA;
        #CLK_PERIOD;
        $display("Load Data: Output = %h (Expected AAAAAAAA)", q_out);

        // Test Case 2: Shift Left (Insert 1s at LSB)
        // 0xAAAAAAAA << 1 with '1' should become 0x55555555
        ctrl = 2'b10;
        serial_in_left = 1; // Feeding '1' into LSB
        #CLK_PERIOD; 
        $display("Shift Left: Output = %h", q_out);

        // Test Case 3: Shift Right (Insert 0s at MSB)
        // 0x55555555 >> 2 (shifting in 0s)
        ctrl = 2'b01;
        serial_in_right = 0; // Feeding '0' into MSB
        #(CLK_PERIOD * 2);   // Shift right twice
        $display("Shift Right x2: Output = %h", q_out);

        // Test Case 4: Hold
        ctrl = 2'b00;
        #20;
        $display("Hold Data: Output = %h", q_out);

        // End Simulation
        #20;
        $finish;
    end

endmodule