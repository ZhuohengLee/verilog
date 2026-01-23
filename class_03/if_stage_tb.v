`timescale 1ns / 1ps
module if_stage_tb;
    reg         clk;               // clock
    reg         rst_n;             // reset
    wire [31:0] instr;             // fetched instruction
    wire [31:0] current_pc;        // PC value
    
    if_stage uut (                 // unit under test
        .clk(clk),
        .rst_n(rst_n),
        .instr(instr),
        .current_pc(current_pc)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;     // 10ns period
    end
    
    initial begin
        $dumpfile("if_stage.vcd"); // waveform
        $dumpvars(0, if_stage_tb);
    end
    
    initial begin
        rst_n = 0;                 // apply reset
        #10;
        $display("Current PC: %h | Instr: %h", current_pc, instr);
        rst_n = 1;                 // release reset
        $display("--- IF Stage Test ---");
        
        repeat (5) begin
            @(posedge clk); 
            #1;
            $display("Current PC: %h | Instr: %h", current_pc, instr);
        end
        
        #20;
        $finish;
    end
endmodule