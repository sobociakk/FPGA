`timescale 1ns / 1ps

module rtc_top (
    input logic clk_i,         
    input logic rst_i,         
    
    input logic btn_hr_i,      
    input logic btn_min_i,    
    input logic btn_test_i,    

    output logic [3:0] led7_an_o,  
    output logic [7:0] led7_seg_o 
);

    logic tick_1khz_w;
    logic tick_1hz_w;
    logic blink_dot_w;
    logic btn_hr_tick_w;
    logic btn_min_tick_w;
    logic [4:0] hr_w;
    logic [5:0] min_w;
    logic [5:0] sec_w; 

    timer_unit TIMER_UNIT (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .btn_test_i (btn_test_i),
        .tick_1khz_o (tick_1khz_w),
        .tick_1hz_o (tick_1hz_w),
        .blink_dot_o (blink_dot_w)
    );

    debouncer #( .DEBOUNCE_TIME(5_000_000) ) BTN_HR_DEBOUNCER (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .btn_i (btn_hr_i),
        .btn_tick_o (btn_hr_tick_w)
    );

    debouncer #( .DEBOUNCE_TIME(5_000_000) ) BTN_MIN_DEBOUNCER (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .btn_i (btn_min_i),
        .btn_tick_o (btn_min_tick_w)
    );

    rtc_core RTC_CORE (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .tick_1hz_i (tick_1hz_w),
        .btn_min_tick_i (btn_min_tick_w),
        .btn_hr_tick_i (btn_hr_tick_w),
        .hr_o (hr_w),
        .min_o (min_w),
        .sec_o (sec_w)
    );

    display DISPLAY (
        .clk_i (clk_i),
        .rst_i (rst_i),
        .tick_1khz_i (tick_1khz_w),
        .blink_dot_i (blink_dot_w),
        .hr_i (hr_w),
        .min_i (min_w),
        .led7_an_o (led7_an_o),
        .led7_seg_o (led7_seg_o)
    );
endmodule
