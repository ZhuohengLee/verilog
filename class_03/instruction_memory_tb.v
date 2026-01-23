`timescale 1ns / 1ps
module instruction_memory_tb;
    reg  [31:0] addr;
    wire [31:0] rd;
    instruction_memory uut (
        .addr(addr), 
        .rd(rd)
    );
    initial begin
        $dumpfile("instr_mem.vcd");
        $dumpvars(0, instruction_memory_tb);
    end
    initial begin
        addr = 32'h0000_0000;
        #10;
        if (rd !== 32'h20080005) $error("Addr 0 Failed. Expected 20080005, got %h", rd);
        else $display("Addr 0 Passed: %h", rd);
        addr = 32'h0000_0004;
        #10;
        if (rd !== 32'h2009000A) $error("Addr 4 Failed. Expected 2009000A, got %h", rd);
        else $display("Addr 4 Passed: %h", rd);
        addr = 32'h0000_0008;
        #10;
        if (rd !== 32'h01095020) $error("Addr 8 Failed. Expected 01095020, got %h", rd);
        else $display("Addr 8 Passed: %h", rd);
        addr = 32'h0000_0040; 
        #10;
        $display("Addr 64 (Uninitialized): %h", rd);
        $finish;
    end
endmodule