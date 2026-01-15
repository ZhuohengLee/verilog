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

    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // GTKWave
    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, mips_tb);
    end

    // Test Sequence
    initial begin
        rst_n = 0;
        #10;
        rst_n = 1;
        $display("--- MIPS Single Cycle Simulation Start ---");

        // We just let it run. The CPU should execute the memfile.dat automatically.
        // Instr 1: addi $t0, 0, 5   -> Result = 5
        // Instr 2: addi $t1, 0, 10  -> Result = 10
        // Instr 3: add $t2, t0, t1  -> Result = 15
        // Instr 4: sw $t2, 4($0)    -> Store 15 at Addr 4
        
        repeat (15) begin
            @(negedge clk);
            #1;
            $display("Time: %0t | PC: %h | ALU Result: %d", $time, pc_out, alu_result);
        end

        $finish;
    end

endmodule