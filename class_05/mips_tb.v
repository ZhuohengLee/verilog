`timescale 1ns / 1ps
module mips_tb;
    reg         clk;               // clock signal for the processor
    reg         rst_n;             // active-low reset signal
    wire [31:0] pc_out;            // program counter output for monitoring
    wire [31:0] alu_result;        // ALU result output for monitoring
    
    mips uut (                     // instantiate unit under test (UUT)
        .clk(clk),                 // connect clock
        .rst_n(rst_n),             // connect reset
        .pc_out(pc_out),           // monitor PC
        .alu_result(alu_result)    // monitor ALU result
    );
    
    initial begin                  // clock generation process
        clk = 0;                   // initialize clock to 0
        forever #5 clk = ~clk;     // generate 10ns clock period
    end
    
    initial begin                  // waveform generation
        $dumpfile("mips.vcd");     // specify VCD file name
        $dumpvars(0, mips_tb);     // dump all variables in the testbench
    end
    
    initial begin                  // simulation control process
        rst_n = 0;                 // assert reset
        #10;                       // wait for 10ns
        rst_n = 1;                 // release reset
        
        $display("==========================================="); // header
        $display("   MIPS Single Cycle Simulation Start    ");    // message
        $display("==========================================="); // header
        
        repeat (15) begin          // run for 15 clock cycles
            @(negedge clk);        // wait for falling edge of clock
            #1;                    // wait for signal stabilization
            $display("PC: 0x%h | ALU Result: %d", pc_out, alu_result); // log results
        end
        
        $display("==========================================="); // footer
        $display("   Simulation Complete                   ");    // message
        $display("==========================================="); // footer
        $finish;                   // terminate simulation
    end
endmodule