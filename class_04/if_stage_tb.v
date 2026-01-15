`timescale 1ns / 1ps

module if_stage_tb;

    // Signal Declarations
    reg         clk;
    reg         rst_n;
    wire [31:0] instr;
    wire [31:0] current_pc;

    // Instantiate Unit Under Test (UUT)
    if_stage uut (
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),
        .current_pc(current_pc)
    );

    // Clock Generation (Period = 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // GTKWave Setup
    initial begin
        $dumpfile("if_stage.vcd");
        $dumpvars(0, if_stage_tb);
    end

    // Test Sequence
    initial begin
        // 1. Initialize and Reset
        rst_n = 0;
        #10;
        
        // 2. Release Reset, CPU starts running
        rst_n = 1;
        $display("--- CPU Reset Released ---");

        // 3. Observe instruction fetch for the first 5 cycles
        // Expected behavior:
        // Cycle 1: PC=0, Instr=20080005
        // Cycle 2: PC=4, Instr=2009000A
        // Cycle 3: PC=8, Instr=01095020
        // ...
        
        repeat (5) begin
            @(posedge clk); // Wait for clock edge
            #1;             // Wait a bit for data stability
            $display("Time: %0t | PC: %h | Instr: %h", $time, current_pc, instr);
        end

        // 4. End Simulation
        #20;
        $finish;
    end

endmodule