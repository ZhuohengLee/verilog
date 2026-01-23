`timescale 1ns / 1ps
module hazard_unit (
    input  wire [4:0] rs_E, rt_E,     // EX stage src regs
    input  wire [4:0] write_reg_M,
    input  wire [4:0] write_reg_W,
    input  wire       reg_write_M,
    input  wire       reg_write_W,
    input  wire [4:0] rs_D, rt_D,     // ID stage src regs
    input  wire [4:0] rt_E_load,      // load dest reg
    input  wire       mem_to_reg_E,   // is load?
    output reg  [1:0] forward_a_E,
    output reg  [1:0] forward_b_E,
    output wire       stall_F,        // freeze PC
    output wire       stall_D,        // freeze IF/ID
    output wire       flush_E         // insert bubble
);
    wire lwstall;  // load-use stall
    
    always @(*) begin
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rs_E))
            forward_a_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rs_E))
            forward_a_E = 2'b01;
        else
            forward_a_E = 2'b00;
            
        if (reg_write_M && (write_reg_M != 0) && (write_reg_M == rt_E))
            forward_b_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 0) && (write_reg_W == rt_E))
            forward_b_E = 2'b01;
        else
            forward_b_E = 2'b00;
    end
    
    assign lwstall = mem_to_reg_E && ((rt_E_load == rs_D) || (rt_E_load == rt_D));
    assign stall_F = lwstall;
    assign stall_D = lwstall;
    assign flush_E = lwstall;
endmodule