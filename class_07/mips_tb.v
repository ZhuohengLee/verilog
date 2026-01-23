`timescale 1ns / 1ps
//==============================================================================
// Week 7: Pipeline Integration & Timing Analysis Testbench
// Verifies that instructions and control signals remain synchronized
//==============================================================================

module mips_tb;
    reg         clk;
    reg         rst_n;
    wire [31:0] pc_out;
    wire [31:0] alu_result;

    // Unit Under Test
    mips uut (
        .clk(clk),
        .rst_n(rst_n),
        .pc_out(pc_out),
        .alu_result(alu_result)
    );

    // Clock generation (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Waveform dump
    initial begin
        $dumpfile("mips.vcd");
        $dumpvars(0, mips_tb);
    end

    // Simulation
    initial begin
        rst_n = 0;
        #15;                            // Hold reset for 1.5 cycles
        rst_n = 1;

        $display("==============================================");
        $display("  Week 6: 5-Stage Pipeline Simulation Start  ");
        $display("==============================================");
        $display("Note: Results appear with pipeline delay!");
        $display("");

        // Run for 20 cycles to see pipeline fill and drain
        repeat (20) begin
            @(negedge clk);
            #1;
            $display("Cycle | PC: 0x%h | WB Result: %d", pc_out, alu_result);
        end

        $display("");
        $display("==============================================");
        $display("         Simulation Complete                 ");
        $display("==============================================");
        $finish;
    end

endmodule