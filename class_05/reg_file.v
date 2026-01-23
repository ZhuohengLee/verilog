`timescale 1ns / 1ps
module reg_file (
    input  wire        clk,            // clock signal
    input  wire        we3,            // write enable for register port 3
    input  wire [4:0]  wa3,            // write address for register port 3
    input  wire [31:0] wd3,            // write data for register port 3
    input  wire [4:0]  ra1,            // read address for register port 1
    input  wire [4:0]  ra2,            // read address for register port 2
    output wire [31:0] rd1,            // read data output from port 1
    output wire [31:0] rd2             // read data output from port 2
);
    reg [31:0] rf [31:0];              // internal register array (32x32-bit)
    
    always @(posedge clk) begin       // synchronous write
        if (we3 && (wa3 != 5'd0))      // write if enabled and not register $0
            rf[wa3] <= wd3;            // perform write operation
    end
    
    assign rd1 = (ra1 == 5'd0) ? 32'd0 : rf[ra1];  // register $0 is always 0
    assign rd2 = (ra2 == 5'd0) ? 32'd0 : rf[ra2];  // register $0 is always 0
endmodule