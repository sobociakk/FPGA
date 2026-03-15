`timescale 1ns / 1ps

module uart_rx_top #(
    parameter int CLK_FREQ = 100000000,
    parameter int BAUD_RATE = 9600,
    parameter int FIFO_DEPTH = 16
)(
    uart_rx_if.mac_mp bus_o, 

    input logic clk_i,
    input logic rst_ni,
    input logic rx_i         
);

    logic baud_tick_16x_w;
    logic full_w;
    logic empty_w;

    
    uart_rx_if rx_to_fifo_if();

    
    baud_rate_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE * 16) 
    ) BAUD_GEN_UNIT (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .enable_i(1'b1),
        .tick_o(baud_tick_16x_w)
    );

    uart_rx UART_RX_UNIT (
        .bus_i(rx_to_fifo_if.mac_mp),
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .baud_tick_i(baud_tick_16x_w),
        .rx_i(rx_i)
    );

    fifo #(
        .DATA_WIDTH(8),
        .DEPTH(FIFO_DEPTH)
    ) FIFO_UNIT (
        .clk_i(clk_i),
        .rst_ni(rst_ni),
        .wr_en_i(rx_to_fifo_if.valid),
        .wr_data_i(rx_to_fifo_if.data),
        .full_o(full_w),
        .rd_en_i(bus_o.ready),
        .rd_data_o(bus_o.data), 
        .empty_o(empty_w)
    );

    assign rx_to_fifo_if.ready = !full_w;
    assign bus_o.valid = !empty_w;

endmodule