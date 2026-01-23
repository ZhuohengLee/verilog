`timescale 1ns / 1ps
module forwarding_unit (
    input  wire [4:0] rs_E,          // src reg A in EX
    input  wire [4:0] rt_E,          // src reg B in EX
    input  wire [4:0] write_reg_M,   // dest reg in MEM
    input  wire       reg_write_M,   // write enable MEM
    input  wire [4:0] write_reg_W,   // dest reg in WB
    input  wire       reg_write_W,   // write enable WB
    output reg  [1:0] forward_a_E,   // 00=reg, 01=WB, 10=MEM
    output reg  [1:0] forward_b_E
);
    always @(*) begin
        if (reg_write_M && (write_reg_M != 5'd0) && (write_reg_M == rs_E))
            forward_a_E = 2'b10;       // forward from MEM
        else if (reg_write_W && (write_reg_W != 5'd0) && (write_reg_W == rs_E))
            forward_a_E = 2'b01;       // forward from WB
        else
            forward_a_E = 2'b00;       // no forward
    end
    
    always @(*) begin
        if (reg_write_M && (write_reg_M != 5'd0) && (write_reg_M == rt_E))
            forward_b_E = 2'b10;
        else if (reg_write_W && (write_reg_W != 5'd0) && (write_reg_W == rt_E))
            forward_b_E = 2'b01;
        else
            forward_b_E = 2'b00;
    end
endmodule