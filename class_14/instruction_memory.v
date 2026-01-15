`timescale 1ns / 1ps

module instruction_memory (
    input  wire [31:0] addr,
    output wire [31:0] rd
);

    reg [31:0] ram [0:255];

    initial begin
        $readmemh("memfile.dat", ram);
    end

    assign rd = ram[addr[9:2]]; // Word aligned

endmodule