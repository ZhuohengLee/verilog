`timescale 1ns / 1ps
module main_decoder (
    input  wire [5:0] opcode,       // instruction opcode
    
    output wire       mem_to_reg,   // write-back select: 1=memory, 0=ALU
    output wire       mem_write,    // memory write enable (for sw)
    output wire       branch,       // branch enable signal (for beq)
    output wire       alu_src,      // ALU source select: 1=immediate, 0=register
    output wire       reg_dst,      // register destination select: 1=rd, 0=rt
    output wire       reg_write,    // register file write enable
    output wire [1:0] alu_op        // ALU operation type for ALU decoder
);
    reg [7:0] controls;             // internal control signal vector (8 bits)
    // assign control bits from the vector
    assign {reg_write, reg_dst, alu_src, branch, mem_write, mem_to_reg, alu_op} = controls;
    
    always @(*) begin              // combinatorial decoding logic
        case (opcode)              // decode based on opcode
            6'b000000: controls = 8'b1_1_0_0_0_0_10; // R-type instructions
            6'b100011: controls = 8'b1_0_1_0_0_1_00; // lw (load word)
            6'b101011: controls = 8'b0_0_1_0_1_0_00; // sw (store word)
            6'b000100: controls = 8'b0_0_0_1_0_0_01; // beq (branch equal)
            6'b001000: controls = 8'b1_0_1_0_0_0_00; // addi (add immediate)
            default:   controls = 8'b0_0_0_0_0_0_00; // default (illegal opcode)
        endcase
    end
endmodule