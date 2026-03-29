module uart_rx #(
    parameter CLKS_PER_BIT = 434 // 50MHz / 115200 Baud = 434
)(
    input  wire       clk,       // System Clock
    input  wire       reset,     // System Reset
    input  wire       rx_serial, // UART RX line
    output reg [7:0]  rx_byte,   // Final data byte
    output reg        rx_done,   // Pulse when byte is ready
    output reg        parity_err // High if parity check fails
);

    // 4-State FSM
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0]  state = IDLE;
    reg [15:0] clk_count = 0;
    reg [2:0]  bit_index = 0;
    reg        parity_bit = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            rx_done <= 0;
            parity_err <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (rx_serial == 1'b0) // Start bit detected (falling edge)
                        state <= START;
                end

                START: begin
                    // Wait for middle of start bit to verify it's valid
                    if (clk_count == (CLKS_PER_BIT-1)/2) begin
                        if (rx_serial == 1'b0) begin
                            clk_count <= 0;
                            state <= DATA;
                        end else
                            state <= IDLE;
                    end else begin
                        clk_count <= clk_count + 1;
                    end
                end

                DATA: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_byte[bit_index] <= rx_serial;
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end

                STOP: begin
                    if (clk_count < CLKS_PER_BIT-1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        rx_done <= 1'b1;
                        state   <= IDLE;
                        // Simple Even Parity Check Example:
                        // parity_err <= ^rx_byte; // XOR reduction for parity
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
