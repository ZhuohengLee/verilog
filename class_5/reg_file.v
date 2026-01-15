module reg_file (
    input  wire        clk,
    input  wire        we3,       // Write Enable
    input  wire [4:0]  ra1, ra2,  // Read Addr 1, 2
    input  wire [4:0]  wa3,       // Write Addr
    input  wire [31:0] wd3,       // Write Data
    output wire [31:0] rd1, rd2   // Read Data 1, 2
);

    reg [31:0] rf [31:0];

    // Write Logic (Sequential)
    always @(posedge clk) begin
        if (we3 && (wa3 != 5'd0)) begin
            rf[wa3] <= wd3;
        end
    end

    // Read Logic (Combinational)
    assign rd1 = (ra1 == 5'd0) ? 32'd0 : rf[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'd0 : rf[ra2];

endmodule