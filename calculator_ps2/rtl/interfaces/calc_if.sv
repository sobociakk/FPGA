`timescale 1ns / 1ps

interface calc_if (input logic clk);
    logic ps2_clk;
    logic ps2_data;
    logic rst;
    logic [6:0] led7_seg_o;
    logic [3:0] led7_an_o;

    modport top (
        input ps2_clk,
        input ps2_data,
        input rst,
        output led7_seg_o,
        output led7_an_o
    );

endinterface
