`timescale 1ns / 1ps

module hazard_unit (
    // Forwarding (EX Stage)
    input  wire [4:0] rs_E, rt_E,
    input  wire [4:0] write_reg_M, write_reg_W,
    input  wire       reg_write_M, reg_write_W,
    
    // Stall (ID Stage)
    input  wire [4:0] rs_D, rt_D,
    input  wire       branch_D, 
    input  wire       jr_D,            
    input  wire       reg_write_E, mem_to_reg_E,
    input  wire [4:0] write_reg_E,
    input  wire       mem_to_reg_M,

    // Outputs
    output reg  [1:0] forward_a_E, forward_b_E,
    output reg        forward_a_D, forward_b_D,
    output wire       stall_F, stall_D, flush_E
);

    wire lwstall;
    wire branchstall;

    // 1. ALU Forwarding
    always @(*) begin
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rs_E)) forward_a_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rs_E)) forward_a_E = 2'b01;
        else forward_a_E = 2'b00;

        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rt_E)) forward_b_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rt_E)) forward_b_E = 2'b01;
        else forward_b_E = 2'b00;
    end

    // 2. Comparator/JR Forwarding
    always @(*) begin
        forward_a_D = (reg_write_M && (write_reg_M != 0) && (write_reg_M == rs_D));
        forward_b_D = (reg_write_M && (write_reg_M != 0) && (write_reg_M == rt_D));
    end

    // 3. Stall Logic
    // (A) Load-Use Stall
    assign lwstall = mem_to_reg_E && ((write_reg_E == rs_D) || (write_reg_E == rt_D));

    // (B) Branch/JR Stall
    assign branchstall = 
        ((branch_D || jr_D) && reg_write_E && (write_reg_E == rs_D || (branch_D && write_reg_E == rt_D))) ||
        ((branch_D || jr_D) && mem_to_reg_M && (write_reg_M == rs_D || (branch_D && write_reg_M == rt_D)));

    assign stall_F = lwstall || branchstall;
    assign stall_D = lwstall || branchstall;
    assign flush_E = lwstall || branchstall;

endmodule