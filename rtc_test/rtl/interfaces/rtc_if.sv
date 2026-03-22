`timescale 1ns / 1ps

interface rtc_if(input logic clk);
    logic btn_hr_i;
    logic btn_min_i;
    logic btn_test_i;
    logic [3:0] led7_an_o;
    logic [6:0] led7_seg_o;
    logic dp_o;

    modport top (
        input btn_hr_i, btn_min_i, btn_test_i,
        output led7_an_o, led7_seg_o, dp_o
    );
endinterface
