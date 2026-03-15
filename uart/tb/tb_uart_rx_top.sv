`timescale 1ns / 1ps

module tb_uart_rx_top;

    localparam int CLK_FREQ = 100_000_000;
    localparam int BAUD_RATE = 1_250_000; 
    localparam int BIT_TIME = CLK_FREQ / BAUD_RATE; //  80 cycles

    logic clk;
    logic rst_n;
    logic rx_serial_in;

    uart_rx_if rx_if();

    uart_rx_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(16)
    ) DUT (
        .bus_o(rx_if.mac_mp),
        .clk_i(clk),
        .rst_ni(rst_n),
        .rx_i(rx_serial_in)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ================================================================
    // TASK: Virtual Transmitter (generates serial signal on the wire)
    // ================================================================

    task send_serial_byte(input logic [7:0] data_to_send);
        begin
            rx_serial_in = 1'b0;
            repeat(BIT_TIME) @(posedge clk);

            for(int i = 0; i < 8; i++) begin
                rx_serial_in = data_to_send[i];
                repeat(BIT_TIME) @(posedge clk);
            end

            rx_serial_in = 1'b1;
            repeat(BIT_TIME) @(posedge clk);
        end
    endtask

    // ================================================================
    // Main Testing Tread
    // ================================================================

    initial begin
        rst_n = 1'b0;
        rx_serial_in = 1'b1;
        rx_if.ready = 1'b0;

        #20;
        rst_n = 1'b1;
        #20;

        $display("========================================");
        $display("[TB] Starting UART RX receiver test (+ FIFO)");
        $display("========================================");

        $display("[TB] Sending by wire 8'hA5 (10100101)...");
        send_serial_byte(8'hA5);
        $display("[TB] Virtual TX stop sending.");

        while(rx_if.valid == 1'b0) begin
            @(posedge clk);
        end

        if(rx_if.data == 8'hA5) begin
            $display("[PASS] Host received valid data from FIFO: 8'h%0h!", rx_if.data);
        end else begin
            $error("[FAIL] Host received invalid: 8'h%0h instead of 8'hA5!", rx_if.data);
        end

        @(posedge clk);
        rx_if.ready = 1'b1;
        @(posedge clk);
        rx_if.ready = 1'b0;
        $display("[TB] Operation Read from FIFO executed.");
        repeat(50) @(posedge clk);
        $display("========================================");
        $display("[TB] RX simulation completed.");
        $display("========================================");
        $finish;
    end

endmodule
