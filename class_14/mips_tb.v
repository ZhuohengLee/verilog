`timescale 1ns / 1ps
module mips_tb;
    reg clk, rst_n;
    reg [7:0] switches;
    wire [7:0] leds;
    wire [31:0] pc_out, alu_result;
    wire [31:0] total_cycles, stall_cycles, flush_cycles;

    mips uut (
        .clk(clk), .rst_n(rst_n), 
        .switches(switches), .leds(leds), 
        .pc_out(pc_out), .alu_result(alu_result),
        .total_cycles(total_cycles),
        .stall_cycles(stall_cycles),
        .flush_cycles(flush_cycles)
    );

    initial begin clk = 0; forever #5 clk = ~clk; end
    initial begin $dumpfile("bubble.vcd"); $dumpvars(0, mips_tb); end

    integer cycle_count;
    initial begin
        rst_n = 0; switches = 0; cycle_count = 0;
        #10; rst_n = 1;
        $display("--- Bubble Sort Simulation Start ---");
        $display("Cycle |   PC   | Instr | Stall | Flush | a0=%d v0=%d", uut.u_datapath.u_reg_file.rf[4], uut.u_datapath.u_reg_file.rf[2]);
        
        // Run and trace
        while (cycle_count < 2000 && leds != 8'h0F) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;
            // Trace only first 300 cycles to avoid clutter
            if (cycle_count <= 300) begin
                $display("%5d | %08h | %08h |   %b   |   %b   | rw=%b | v0=%d s0=%d t0=%d t1=%d", 
                         cycle_count, pc_out, uut.instr_D, uut.stall_D, uut.u_hazard.flush_E, uut.reg_write_D,
                         uut.u_datapath.u_reg_file.rf[2],  // v0
                         uut.u_datapath.u_reg_file.rf[16], // s0
                         uut.u_datapath.u_reg_file.rf[8],  // t0
                         uut.u_datapath.u_reg_file.rf[9]   // t1
                );
            end
        end
        
        // Final cycles to let the end instruction move through pipeline
        repeat (5) @(posedge clk);
        
        $display("--- Performance Analysis ---");
        $display("Total Cycles:   %d", total_cycles);
        $display("Stall Cycles:   %d", stall_cycles);
        $display("Flush Cycles:   %d", flush_cycles);
        $display("Final LEDs:     0x%h", leds);
        
        // Check sorted array in memory (using peek if possible, or just look at VCD)
        $display("Array[0]: %d", uut.u_datapath.u_data_mem.ram[0]);
        $display("Array[1]: %d", uut.u_datapath.u_data_mem.ram[1]);
        $display("Array[2]: %d", uut.u_datapath.u_data_mem.ram[2]);
        $display("Array[3]: %d", uut.u_datapath.u_data_mem.ram[3]);
            
        $finish;
    end
endmodule