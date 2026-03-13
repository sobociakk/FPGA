`timescale 1ns / 1ps

// Setup for 9600 Bd with 100MHz 
// 9600 * 16 = 153,600
// 100 * 10^6 / 153,600 = ~651     (counter limit M)
// log2(651) = 10                  (counter limit N)

module uart_top #(
    parameter DBITS = 8,        
              SB_TICK = 16,
              BR_LIMIT = 651,
              BR_BITS = 10,
              FIFO_EXP = 2         // exponent for number of FIFO addresses (2^2 = 4)
    )(
        input clk,
        input rst,
        input read_uart,
        input write_uart,
        input rx,
        input [DBITS-1:0] write_data,

        output rx_full,
        output rx_empty,
        output tx_full,            
        output tx,
        output [DBITS-1:0] read_data
    );

    wire tick;
    wire rx_done_tick;
    wire tx_done_tick;
    wire tx_empty;
    wire tx_fifo_not_empty;
    wire [DBITS-1:0] tx_fifo_out;
    wire [DBITS-1:0] rx_data_out;

    baud_rate_generator #(
        .M(BR_LIMIT),
        .N(BR_BITS)
    ) BAUD_RATE_GEN (
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );

    uart_rx #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
    ) UART_RX_UNIT (
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .sample_tick(tick),
        .data_ready(rx_done_tick),
        .data_out(rx_data_out)
    );
    
    uart_tx #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
    ) UART_TX_UNIT (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_fifo_not_empty),
        .sample_tick(tick),
        .data_in(tx_fifo_out),
        .tx_done(tx_done_tick),
        .tx(tx)
    );
    
    fifo #(
        .DATA_SIZE(DBITS),
        .ADDR_SPACE_EXP(FIFO_EXP)
    ) FIFO_RX_UNIT (
        .clk(clk),
        .reset(rst),
        .write_to_fifo(rx_done_tick),
        .read_from_fifo(read_uart),
        .write_data_in(rx_data_out),
        .read_data_out(read_data),
        .empty(rx_empty),
        .full(rx_full)            
    );
       
    fifo #(
        .DATA_SIZE(DBITS),
        .ADDR_SPACE_EXP(FIFO_EXP)
    ) FIFO_TX_UNIT (
        .clk(clk),
        .reset(rst),
        .write_to_fifo(write_uart),
        .read_from_fifo(tx_done_tick),
        .write_data_in(write_data),
        .read_data_out(tx_fifo_out),
        .empty(tx_empty),
        .full(tx_full)             // DODANE: podlaczenie wyjscia
    );
    
    assign tx_fifo_not_empty = ~tx_empty;

endmodule