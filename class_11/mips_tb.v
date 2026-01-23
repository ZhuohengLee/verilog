`timescale 1ns / 1ps
module mips_tb;
    reg clk, rst_n;
    wire [31:0] pc_out, alu_result;
    mips uut (.clk(clk), .rst_n(rst_n), .pc_out(pc_out), .alu_result(alu_result));
    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin $dumpfile("branch.vcd"); $dumpvars(0, mips_tb); end
    initial begin
        rst_n = 0; #10; rst_n = 1;
        $display("--- ID Branch Simulation Start ---");
        repeat (15) begin
            @(negedge clk);
            if (alu_result !== 0 && alu_result[0] !== 1'bx)
                $display("Time: %0t | PC: %h | WB Result: %d", $time, pc_out, alu_result);
            @(posedge clk);
        end
        $finish;
    end
endmodule