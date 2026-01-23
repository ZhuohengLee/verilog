`timescale 1ns / 1ps

module pc (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [31:0] pc_next,  // Address of the next instruction
    output reg  [31:0] pc        // Current PC address
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'd0; // On reset, start from address 0
        end else begin
            pc <= pc_next; // On clock edge, update to next address
        end
    end

endmodule