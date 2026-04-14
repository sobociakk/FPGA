`timescale 1ns / 1ps
`default_nettype none

//  calc_if - System interface + Clocking Block
//   - inputs sampled #1step before posedge (reads DUT outputs)
//   - outputs driven #1 after posedge (writes to DUT inputs)
//  Eliminates race between TB drive/sample and DUT clock edge

interface calc_if(input wire logic clk);

    logic ps2_clk;
    logic ps2_data;
    logic rst;
    logic [6:0] led7_seg_o;
    logic [3:0] led7_an_o;

    clocking tb_cb @(posedge clk);
        default input #1step output #1;
        output ps2_clk, ps2_data, rst;
        input led7_seg_o, led7_an_o;
    endclocking

    modport tb(clocking tb_cb, input clk);

    modport dut(
        input ps2_clk, ps2_data, rst, 
        output led7_seg_o, led7_an_o
    );

endinterface
`default_nettype wire
