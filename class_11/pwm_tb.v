`timescale 1ns / 1ps
module pwm_tb;
    reg        clk, rst_n, enable; // control signals
    reg  [7:0] duty_cycle;         // PWM duty (0-255)
    wire       pwm_out;            // PWM output
    
    pwm_controller #(
        .CLK_FREQ(1000),           // 1kHz for fast sim
        .PWM_FREQ(100)             // 100Hz = 10 clocks/period
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        .enable(enable),
        .duty_cycle(duty_cycle),
        .pwm_out(pwm_out)
    );
    
    initial begin 
        clk = 0; 
        forever #5 clk = ~clk;     // 10ns period
    end
    
    initial begin
        $dumpfile("pwm.vcd");      // waveform
        $dumpvars(0, pwm_tb);
    end
    
    integer high_count, total_count;
    real measured_duty;
    
    initial begin
        // Initialize
        rst_n = 0; enable = 0; duty_cycle = 0;
        high_count = 0; total_count = 0;
        #20; 
        rst_n = 1;
        
        $display("===========================================");
        $display("     PWM Controller Testbench            ");
        $display("===========================================");
        
        // Test 1: 50% duty (128/256)
        duty_cycle = 128; enable = 1;
        high_count = 0; total_count = 0;
        repeat (100) begin
            @(posedge clk);
            if (pwm_out) high_count = high_count + 1;
            total_count = total_count + 1;
        end
        measured_duty = (high_count * 100.0) / total_count;
        if (measured_duty > 45 && measured_duty < 55)
            $display("Test 1 PASSED: 50%% duty = %.1f%%", measured_duty);
        else
            $display("Test 1 FAILED: got %.1f%%", measured_duty);
        
        // Test 2: 25% duty (64/256)
        duty_cycle = 64; enable = 1;
        high_count = 0; total_count = 0;
        repeat (100) begin
            @(posedge clk);
            if (pwm_out) high_count = high_count + 1;
            total_count = total_count + 1;
        end
        measured_duty = (high_count * 100.0) / total_count;
        if (measured_duty > 15 && measured_duty < 35)
            $display("Test 2 PASSED: 25%% duty = %.1f%%", measured_duty);
        else
            $display("Test 2 FAILED: got %.1f%%", measured_duty);
        
        // Test 3: 75% duty (192/256)
        duty_cycle = 192; enable = 1;
        high_count = 0; total_count = 0;
        repeat (100) begin
            @(posedge clk);
            if (pwm_out) high_count = high_count + 1;
            total_count = total_count + 1;
        end
        measured_duty = (high_count * 100.0) / total_count;
        if (measured_duty > 65 && measured_duty < 85)
            $display("Test 3 PASSED: 75%% duty = %.1f%%", measured_duty);
        else
            $display("Test 3 FAILED: got %.1f%%", measured_duty);
        
        // Test 4: Disable PWM
        enable = 0;
        #50;
        if (pwm_out == 0) 
            $display("Test 4 PASSED: PWM disabled");
        else 
            $display("Test 4 FAILED");
        
        $display("===========================================");
        $display("     PWM Tests Complete                  ");
        $display("===========================================");
        $finish;
    end
endmodule