`timescale 1ns / 1ps

module uart_top #(
    parameter int CLK_FREQ = 100_000_000,
    parameter int BAUD_RATE = 115200,
    parameter int FIFO_DEPTH = 16
)(
    input logic clk_i,
    input logic rst_ni,
    input logic rx_i,

    output logic tx_o,

    uart_tx_if.mac_mp bus_tx_i, 
    uart_rx_if.mac_mp bus_rx_o  
);

    uart_tx_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) UART_TX (
        .bus_i(bus_tx_i),
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .tx_o(tx_o)
    );

    uart_rx_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) UART_RX (
        .bus_o(bus_rx_o),
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .rx_i(rx_i)
    );

endmodule