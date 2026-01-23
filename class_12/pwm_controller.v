`timescale 1ns / 1ps
module pwm_controller #(
    parameter CLK_FREQ = 50_000_000,  // 50MHz
    parameter PWM_FREQ = 10_000       // 10kHz
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        enable,
    input  wire [7:0]  duty_cycle,    // 0-255 = 0-100%
    output reg         pwm_out
);
    localparam PERIOD = CLK_FREQ / PWM_FREQ;
    localparam COUNTER_WIDTH = $clog2(PERIOD);
    
    reg [COUNTER_WIDTH-1:0] counter;
    wire [COUNTER_WIDTH-1:0] threshold;
    
    assign threshold = (duty_cycle * PERIOD) >> 8;  // duty/256 * period
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            counter <= 0;
        else if (enable) begin
            if (counter >= PERIOD - 1)
                counter <= 0;          // wrap
            else
                counter <= counter + 1;
        end else
            counter <= 0;
    end
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            pwm_out <= 0;
        else if (enable)
            pwm_out <= (counter < threshold);  // high when counter < threshold
        else
            pwm_out <= 0;
    end
endmodule