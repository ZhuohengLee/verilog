`timescale 1ns / 1ps

module reg_file (
    input  wire        clk,
    input  wire        we3,
    input  wire [4:0]  ra1, ra2, wa3,
    input  wire [31:0] wd3,
    output wire [31:0] rd1, rd2
);

    reg [31:0] rf [0:31];

    // Initialize all registers to 0 (essential for simulation)
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] = 32'd0;
    end

    always @(negedge clk) begin // Write on falling edge
        if (we3) rf[wa3] <= wd3;
    end

    // Add internal forwarding (bypass) during read:
    // When writing and reading to the same register in the same cycle, return the data to be written
    assign rd1 = (ra1 == 0) ? 32'd0 :
                 (we3 && (wa3 == ra1)) ? wd3 : rf[ra1];
    assign rd2 = (ra2 == 0) ? 32'd0 :
                 (we3 && (wa3 == ra2)) ? wd3 : rf[ra2];

endmodule