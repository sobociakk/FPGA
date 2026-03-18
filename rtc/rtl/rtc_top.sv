`timescale 1ns / 1ps

module rtc_top (
    input logic clk_i,         
    input logic rst_i,         
    input logic btn_hr_i,      
    input logic btn_min_i,    
    input logic btn_test_i,    

    output logic [3:0] led7_an_o,  
    output logic [6:0] led7_seg_o,
    output logic dp_o 
);

logic tick_1khz_w;
logic tick_1hz_w;
logic blink_dot_w;
logic btn_test_w;
logic btn_hr_tick_w;
logic btn_min_tick_w;
logic [3:0] hr_t_w;
logic [3:0] hr_u_w;
logic [3:0] min_t_w;
logic [3:0] min_u_w;
logic [3:0] sec_t_w;
logic [3:0] sec_u_w;

timer_unit TIMER_UNIT (
    .clk_i (clk_i),
    .rst_i (rst_i),
    .btn_test_i (btn_test_w),
    .tick_1khz_o (tick_1khz_w),
    .tick_1hz_o (tick_1hz_w),
    .blink_dot_o (blink_dot_w)
);

debouncer #( .DEBOUNCE_CYCLES(5_000_000) ) BTN_TEST_DEBOUNCER (
    .clk_i (clk_i),
    .rst_i (rst_i),
    .btn_async_i (btn_test_i),
    .btn_tick_o (btn_test_w)
);

debouncer #( .DEBOUNCE_CYCLES(5_000_000) ) BTN_HR_DEBOUNCER (
    .clk_i (clk_i),
    .rst_i (rst_i),
    .btn_async_i (btn_hr_i),
    .btn_tick_o (btn_hr_tick_w)
);

debouncer #( .DEBOUNCE_CYCLES(5_000_000) ) BTN_MIN_DEBOUNCER (
    .clk_i (clk_i),
    .rst_i (rst_i),
    .btn_async_i (btn_min_i),
    .btn_tick_o (btn_min_tick_w)
);

rtc_core RTC_CORE (
    .clk_i (clk_i),
    .rst_i (rst_i),
    .tick_1hz_i (tick_1hz_w),
    .btn_min_tick_i (btn_min_tick_w),
    .btn_hr_tick_i (btn_hr_tick_w),
    .hr_t_o(hr_t_w),
    .hr_u_o(hr_u_w),
    .min_t_o(min_t_w),
    .min_u_o(min_u_w),
    .sec_t_o(sec_t_w),
    .sec_u_o(sec_u_w)
);

display DISPLAY (
    .clk_i (clk_i),
    .rst_i (rst_i),
    .tick_1khz_i (tick_1khz_w),
    .blink_dot_i (blink_dot_w),
    .hr_t_i(hr_t_w),
    .hr_u_i(hr_u_w),
    .min_t_i(min_t_w),
    .min_u_i(min_u_w),
    .led7_an_o (led7_an_o),
    .led7_seg_o (led7_seg_o),
    .dp_o(dp_o)
);
endmodule
