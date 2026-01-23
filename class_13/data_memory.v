`timescale 1ns / 1ps
module data_memory (
    input  wire        clk,
    input  wire        mem_write_en,
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    input  wire [7:0]  switches,    
    output reg  [7:0]  leds,        
    output reg  [31:0] read_data
);
    reg [31:0] ram [0:255];
    wire [31:0] ram_out;
    assign ram_out = ram[addr[9:2]]; 
    always @(posedge clk) begin
        if (mem_write_en) begin
            if (addr == 32'h00000094) begin
                leds <= write_data[7:0];
                $display("IO WRITE: LEDs Updated to %b (%d)", write_data[7:0], write_data[7:0]);
            end
            else begin
                ram[addr[9:2]] <= write_data;
            end
        end
    end
    always @(*) begin
        if (addr == 32'h00000090) begin
            read_data = {24'b0, switches}; 
        end
        else begin
            read_data = ram_out;
        end
    end
    initial begin
        leds = 8'h00;
    end
endmodule