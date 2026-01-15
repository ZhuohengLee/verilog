module shift_register #(
    parameter WIDTH = 32  // Parameter for register width, default is 32-bit
)(
    input  wire             clk,             // System clock
    input  wire             rst_n,           // Active low asynchronous reset
    input  wire [1:0]       ctrl,            // Control: 00=Hold, 01=Shift Right, 10=Shift Left, 11=Load
    input  wire [WIDTH-1:0] d_in,            // Parallel data input (for Load mode)
    input  wire             serial_in_left,  // Serial input for Shift Left (LSB input)
    input  wire             serial_in_right, // Serial input for Shift Right (MSB input)
    output reg  [WIDTH-1:0] q_out            // Register output
);

    // Sequential Logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Asynchronous Reset: Clear register
            q_out <= {WIDTH{1'b0}};
        end
        else begin
            case (ctrl)
                2'b00: begin
                    // Hold: Maintain current value
                    q_out <= q_out;
                end
                
                2'b01: begin
                    // Shift Right: MSB gets serial_in_right, LSB is discarded
                    // Example: [3,2,1,0] -> [New,3,2,1]
                    q_out <= {serial_in_right, q_out[WIDTH-1:1]};
                end
                
                2'b10: begin
                    // Shift Left: LSB gets serial_in_left, MSB is discarded
                    // Example: [3,2,1,0] -> [2,1,0,New]
                    q_out <= {q_out[WIDTH-2:0], serial_in_left};
                end
                
                2'b11: begin
                    // Parallel Load: Load new data from d_in
                    q_out <= d_in;
                end
                
                default: begin
                    // Default safe state: Hold
                    q_out <= q_out;
                end
            endcase
        end
    end

endmodule