`timescale 1ns / 1ps
module instruction_memory #(
    parameter WIDTH = 32,          // instruction width
    parameter DEPTH = 256          // memory depth (number of instructions)
)(
    input  wire [31:0] addr,       // instruction address (byte address)
    output wire [31:0] rd          // instruction data output
);
    reg [WIDTH-1:0] ram [0:DEPTH-1]; // internal memory array
    
    initial begin                  // initialize memory
        $readmemh("memfile.dat", ram);  // load program from hex file
    end
    
    assign rd = ram[addr[31:2]];   // word aligned read (divide address by 4)
endmodule