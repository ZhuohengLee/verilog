`timescale 1ns / 1ps

module forwarding_unit (
    input  wire [4:0] rs_E,          // Source Register Rs from EX stage
    input  wire [4:0] rt_E,          // Source Register Rt from EX stage
    input  wire [4:0] write_reg_M,   // Destination Register from MEM stage
    input  wire       reg_write_M,   // Write Enable signal from MEM stage
    input  wire [4:0] write_reg_W,   // Destination Register from WB stage
    input  wire       reg_write_W,   // Write Enable signal from WB stage
    output reg  [1:0] forward_a_E,   // ALU Operand A Mux Select
    output reg  [1:0] forward_b_E    // ALU Operand B Mux Select
);

    // Forwarding Logic for ALU Input A
    always @(*) begin
        // 1. EX Hazard: Data is in MEM stage but not yet written back
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rs_E)) begin
            forward_a_E = 2'b10; // Select ALU Result from MEM stage (Forwarding)
        end
        // 2. MEM Hazard: Data is in WB stage but not yet written back
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rs_E)) begin
            forward_a_E = 2'b01; // Select Result from WB stage (Forwarding)
        end
        // 3. No Hazard: Use data from Register File (ID/EX pipeline reg)
        else begin
            forward_a_E = 2'b00; 
        end
    end

    // Forwarding Logic for ALU Input B
    always @(*) begin
        // 1. EX Hazard
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rt_E)) begin
            forward_b_E = 2'b10;
        end
        // 2. MEM Hazard
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rt_E)) begin
            forward_b_E = 2'b01;
        end
        // 3. No Hazard
        else begin
            forward_b_E = 2'b00;
        end
    end

endmodule