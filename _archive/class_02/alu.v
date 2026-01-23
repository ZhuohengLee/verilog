module alu (
    input  wire [31:0] src_a,     // Operand A
    input  wire [31:0] src_b,     // Operand B
    input  wire [2:0]  alu_ctrl,  // Control Signal
    output reg  [31:0] result,    // ALU Result
    output wire        zero       // Zero Flag
);

    always @(*) begin
        case (alu_ctrl)
            3'b010: result = src_a + src_b; // ADD
            3'b110: result = src_a - src_b; // SUB
            
            // CRITICAL TOPIC: SLT (Set Less Than)
            3'b111: begin

                if ($signed(src_a) < $signed(src_b)) 
                    result = 32'd1;
                else 
                    result = 32'd0;
                    
            end
            
            default: result = 32'd0;
        endcase
    end

    // The Zero flag is High whenever the result is exactly 0.
    assign zero = (result == 32'd0); 

endmodule