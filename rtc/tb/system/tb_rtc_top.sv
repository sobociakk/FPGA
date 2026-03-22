`timescale 1ns / 1ps
`default_nettype none

module tb_rtc_top;
    import rtc_env_pkg::*;
    
    logic clk;
    logic rst;

    initial clk = 1'b0;
    always #5 clk = ~clk;

    rtc_if if_rtc(.clk(clk));

    rtc_top #(.DEBOUNCE_CYCLES(10), .CYCLES_1KHZ(10), .TICKS_1HZ(10)) DUT (
        .clk_i(clk),
        .rst_i(rst),
        .if_rtc(if_rtc.top)
    );

    initial begin
        rtc_test current_test;
        current_test = new(if_rtc);

        rst = 1'b1;
        if_rtc.btn_hr_i = 1'b0;
        if_rtc.btn_min_i = 1'b0;
        if_rtc.btn_test_i = 1'b0;
        
        repeat(5) @(negedge clk);
        rst = 1'b0;
        repeat(10) @(posedge clk); 

        current_test.run();
    end
endmodule
