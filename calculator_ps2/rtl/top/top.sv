`timescale 1ns / 1ps

module top(
    input logic clk,      
    input logic btnC,     
    input logic PS2Clk,    
    input logic PS2Data,   

    output logic [6:0] seg, 
    output logic [3:0] an   
);

    logic rx_done_tick;
    logic [7:0] rx_data;
    logic key_valid;
    logic is_digit;
    logic [3:0] digit_val;
    logic is_plus;
    logic is_minus;
    logic is_equal;
    logic is_esc;
    logic [15:0] alu_result;
    logic [15:0] alu_arg1;
    logic [15:0] alu_arg2;
    logic [1:0] alu_op;
    logic [15:0] display_val;

    ps2_rx #(.CLK_FREQ(100_000_000)) PS2_RX(
        .clk_i(clk),
        .rst_i(btnC),
        .ps2_clk(PS2Clk),
        .ps2_data(PS2Data),
        .rx_done_tick(rx_done_tick),
        .rx_data(rx_data)
    );

    key_decoder KEY_DECODER(
        .clk_i(clk),
        .rst_i(btnC),
        .rx_done_tick(rx_done_tick),
        .rx_data(rx_data),
        .key_valid(key_valid),
        .is_digit(is_digit),
        .digit_val(digit_val),
        .is_plus(is_plus),
        .is_minus(is_minus),
        .is_equal(is_equal),
        .is_esc(is_esc)
    );

    calculator_fsm CALCULATOR_FSM(
        .clk_i(clk),
        .rst_i(btnC),
        .key_valid(key_valid),
        .is_digit(is_digit),
        .digit_val(digit_val),
        .is_plus(is_plus),
        .is_minus(is_minus),
        .is_equal(is_equal),
        .is_esc(is_esc),
        .alu_result(alu_result),
        .alu_arg1(alu_arg1),
        .alu_arg2(alu_arg2),
        .alu_op(alu_op),
        .display_val(display_val)
    );

    alu ALU(
        .alu_arg1(alu_arg1),
        .alu_arg2(alu_arg2),
        .alu_op(alu_op),
        .alu_result(alu_result)
    );

    display #(.CYCLES_1KHZ(100_000)) DISPLAY(
        .clk_i(clk),
        .rst_i(btnC),
        .display_val(display_val),
        .led7_an_o(an),
        .led7_seg_o(seg)
    );
endmodule
