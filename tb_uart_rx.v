`timescale 1ns/1ps

module tb_uart_rx;

    reg clk = 0;
    reg reset = 0;
    reg rx_serial = 1; // Idle high
    wire [7:0] rx_byte;
    wire rx_done;

    // Instantiate RX (Using 10 clocks per bit for fast simulation)
    uart_rx #(.CLKS_PER_BIT(10)) dut (
        .clk(clk),
        .reset(reset),
        .rx_serial(rx_serial),
        .rx_byte(rx_byte),
        .rx_done(rx_done)
    );

    // 100MHz Clock
    always #5 clk = ~clk;

    // Task to send a byte serially
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start Bit
            rx_serial = 0;
            repeat (10) @(posedge clk);
            
            // Data Bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                rx_serial = data[i];
                repeat (10) @(posedge clk);
            end
            
            // Stop Bit
            rx_serial = 1;
            repeat (10) @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("uart_sim.vcd");
        $dumpvars(0, tb_uart_rx);

        reset = 1; #20;
        reset = 0; #20;

        // Send character 'A' (8'h41)
        send_byte(8'h41);
        
        #100;
        if (rx_byte == 8'h41) 
            $display("SUCCESS: Received 0x41");
        else 
            $display("ERROR: Received 0x%h", rx_byte);

        $finish;
    end

endmodule
