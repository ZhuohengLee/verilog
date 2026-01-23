`timescale 1ns / 1ps
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
        #15;
        rst_n = 1;

        $display("==============================================");
        $display("      5-Stage Pipeline Simulation Start       ");
        $display("==============================================");
        $display("Note: Results appear with pipeline delay!");
        $display("");

        // Run for 15 cycles to see pipeline fill and drain
        repeat (15) begin
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