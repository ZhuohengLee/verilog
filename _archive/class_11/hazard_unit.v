`timescale 1ns / 1ps

module hazard_unit (
    // Forwarding Inputs (EX Stage)
    input  wire [4:0] rs_E, rt_E,
    input  wire [4:0] write_reg_M, write_reg_W,
    input  wire       reg_write_M, reg_write_W,
    
    // Stall/Flush Inputs (ID Stage)
    input  wire [4:0] rs_D, rt_D,
    input  wire       branch_D, 
    input  wire       reg_write_E, mem_to_reg_E,
    input  wire [4:0] write_reg_E,
    input  wire       mem_to_reg_M,
    
    // Outputs
    output reg  [1:0] forward_a_E, forward_b_E, // ALU Forwarding
    output reg        forward_a_D, forward_b_D, // Comparator Forwarding (NEW)
    output wire       stall_F, stall_D,         // Stall Signals
    output wire       flush_E, flush_D          // Flush Signals (flush_D is NEW)
);

    wire lwstall;
    wire branchstall;

    // =====================================================
    // 1. Forwarding Logic for EX Stage (ALU)
    // =====================================================
    always @(*) begin
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rs_E)) forward_a_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rs_E)) forward_a_E = 2'b01;
        else forward_a_E = 2'b00;

        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rt_E)) forward_b_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rt_E)) forward_b_E = 2'b01;
        else forward_b_E = 2'b00;
    end

    // =====================================================
    // 2. Forwarding Logic for ID Stage (Branch Comparator)
    // =====================================================
    always @(*) begin
        // Forward A for Comparator
        // Check MEM stage (Data is in alu_result_M)
        forward_a_D = (reg_write_M && (write_reg_M != 0) && (write_reg_M == rs_D));
        
        // Forward B for Comparator
        forward_b_D = (reg_write_M && (write_reg_M != 0) && (write_reg_M == rt_D));
    end

    // =====================================================
    // 3. Stall Logic
    // =====================================================
    
    // (A) Load-Use Stall (Week 10)
    assign lwstall = mem_to_reg_E && ((write_reg_E == rs_D) || (write_reg_E == rt_D));

    // (B) Branch Stall (Week 11 NEW)
    assign branchstall = (branch_D && reg_write_E && (write_reg_E == rs_D || write_reg_E == rt_D)) ||
                         (branch_D && mem_to_reg_M && (write_reg_M == rs_D || write_reg_M == rt_D));

    // Global Stall Signals
    assign stall_F = lwstall || branchstall;
    assign stall_D = lwstall || branchstall;
    assign flush_E = lwstall || branchstall; // Insert Bubble in EX if stalling in ID

    // =====================================================
    // 4. Flush Logic (Control Hazard)
    // =====================================================
    assign flush_D = 0; // Handled in Datapath logic via pc_src

endmodule