`timescale 1ns / 1ps

module instruction_memory #(
    parameter WIDTH = 32,
    parameter DEPTH = 256  // Simulate a memory space of 256 words
)(
    input  wire [31:0] addr, // PC input address (e.g., 0, 4, 8...)
    output wire [31:0] rd    // Read Data (The fetched instruction)
);

    // 1. Define memory array
    reg [WIDTH-1:0] ram [0:DEPTH-1];

    // 2. Initialization: Load machine code file
    initial begin
        // "memfile.dat" must be in the same directory
        // $readmemh reads hexadecimal data into the array
        $readmemh("memfile.dat", ram);
    end

    // 3. Read Logic (Combinational)
    // MIPS memory is word-aligned. Address 4 corresponds to array index 1.
    // We use addr[31:2] to convert byte address to word index.
    assign rd = ram[addr[31:2]];

endmodule