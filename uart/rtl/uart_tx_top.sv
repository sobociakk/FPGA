`timescale 1ns / 1ps

module uart_tx_top # (
    parameter int CLK_FREQ = 100000000,
                  BAUD_RATE = 9600
)(
    uart_tx_if.mac_mp bus_i,

    input logic clk_i,
    input logic rst_ni,

    output logic tx_o
);

    logic baud_rate_w;

    baud_rate_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)    
    ) BAUD_RATE_GEN (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .enable_i(!bus_i.ready),    // starts gen exactly when transmission begins
        .tick_o(baud_rate_w)
    );

    uart_tx UART_TX_UNIT (
        .bus_i(bus_i),
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .baud_tick_i(baud_rate_w),
        .tx_o(tx_o)
    );

endmodule
