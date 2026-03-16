`timescale 1ns / 1ps

module rs232_top #(
    parameter int CLK_FREQ = 100_000_000,
    parameter int BAUD_RATE = 9600
)(
    input logic clk_i,
    input logic rst_i,
    input logic RXD_i,

    output logic TXD_o
);

    logic [7:0] rx_data_w;
    logic rx_valid_w;
    logic [7:0] tx_data_w;
    logic tx_ready_w;
    logic baud_tick_rx_w, baud_tick_tx_w;

    //assign tx_data_w = rx_data_w + 8'h20;

    always_comb begin
        if(rx_data_w >= 8'h41 && rx_data_w <= 8'h5A) begin
            tx_data_w = rx_data_w + 8'h20;
        end else begin
            tx_data_w = rx_data_w;
        end
    end

    baud_rate_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE * 16)
    ) BAUD_RX (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .enable_i(1'b1),
        .tick_o(baud_tick_rx_w)
    );

    baud_rate_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) BAUD_TX (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .enable_i(!tx_ready_w),
        .tick_o(baud_tick_tx_w)
    );

    rs232_rx RS232_RX (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .baud_tick_i(baud_tick_rx_w),
        .rx_i(RXD_i),
        .ready_i(tx_ready_w),

        .data_o(rx_data_w),
        .valid_o(rx_valid_w)
    );

    rs232_tx RS232_TX (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .baud_tick_i(baud_tick_tx_w),
        .data_i(tx_data_w),
        .valid_i(rx_valid_w),

        .ready_o(tx_ready_w),
        .tx_o(TXD_o)
    );

endmodule

