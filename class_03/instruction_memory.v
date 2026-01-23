`timescale 1ns / 1ps
module instruction_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 256
)(
    input  wire [31:0] addr,       // byte address
    output wire [31:0] rd          // instruction
);
    reg [WIDTH-1:0] ram [0:DEPTH-1];
    
    initial begin
        $readmemh("memfile.dat", ram);  // load program
    end
    
    assign rd = ram[addr[31:2]];   // word aligned
endmodule