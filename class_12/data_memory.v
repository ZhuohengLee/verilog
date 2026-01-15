`timescale 1ns / 1ps

module data_memory (
    input  wire        clk,
    input  wire        mem_write_en,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    
    // I/O Ports (New for Week 12)
    input  wire [7:0]  switches,    // Input from slide switches
    output reg  [7:0]  leds,        // Output to LEDs
    
    output reg  [31:0] read_data
);

    // 256-word RAM Memory
    reg [31:0] ram [0:255];
    
    // Internal signal for reading from RAM
    wire [31:0] ram_out;
    assign ram_out = ram[addr[9:2]]; // Word aligned address

    // =====================================================
    // MMIO Logic: Write (LEDs vs RAM)
    // =====================================================
    always @(posedge clk) begin
        if (mem_write_en) begin
            // Address 0x94 (148) -> LEDs
            if (addr == 32'h00000094) begin
                leds <= write_data[7:0];
                $display("IO WRITE: LEDs Updated to %b (%d)", write_data[7:0], write_data[7:0]);
            end
            // Other Addresses -> RAM
            else begin
                ram[addr[9:2]] <= write_data;
            end
        end
    end

    // =====================================================
    // MMIO Logic: Read (Switches vs RAM)
    // =====================================================
    always @(*) begin
        // Address 0x90 (144) -> Switches
        if (addr == 32'h00000090) begin
            read_data = {24'b0, switches}; // Zero-extend 8-bit switch to 32-bit
        end
        // Other Addresses -> RAM
        else begin
            read_data = ram_out;
        end
    end

    // Initialize LEDs
    initial begin
        leds = 8'h00;
    end

endmodule