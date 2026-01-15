`timescale 1ns / 1ps

module hazard_unit (
    // Forwarding Inputs (Same as Week 9)
    input  wire [4:0] rs_E, rt_E,
    input  wire [4:0] write_reg_M, write_reg_W,
    input  wire       reg_write_M, reg_write_W,
    
    // Load-Use Detection Inputs (NEW)
    input  wire [4:0] rs_D, rt_D,      // Source regs from Decode stage
    input  wire [4:0] rt_E_load,       // Target reg from Execute stage (if it's a load)
    input  wire       mem_to_reg_E,    // Is instruction in EX a Load?
    
    // Outputs
    output reg  [1:0] forward_a_E,
    output reg  [1:0] forward_b_E,
    output wire       stall_F,         // Freeze PC
    output wire       stall_D,         // Freeze IF/ID
    output wire       flush_E          // Flush ID/EX (Turn into NOP)
);

    wire lwstall;

    // =====================================================
    // 1. Forwarding Logic (From Week 9)
    // =====================================================
    always @(*) begin
        // Forward A
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rs_E))
            forward_a_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rs_E))
            forward_a_E = 2'b01;
        else
            forward_a_E = 2'b00;

        // Forward B
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rt_E))
            forward_b_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rt_E))
            forward_b_E = 2'b01;
        else
            forward_b_E = 2'b00;
    end

    // =====================================================
    // 2. Load-Use Stall Logic
    // =====================================================
    // If the instruction in EX is a Load (mem_to_reg_E)
    // AND its destination (rt_E_load) matches either source in ID (rs_D, rt_D)
    // THEN we must stall.
    assign lwstall = mem_to_reg_E && 
                     ((rt_E_load == rs_D) || (rt_E_load == rt_D));

    assign stall_F = lwstall; // Freeze PC
    assign stall_D = lwstall; // Freeze IF/ID
    assign flush_E = lwstall; // Clear ID/EX (Bubble)

endmodule