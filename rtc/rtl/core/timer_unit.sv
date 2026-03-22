`timescale 1ns / 1ps

module timer_unit #(
    parameter int CYCLES_1KHZ = 100_000,
    parameter int TICKS_1HZ = 1000
)(
    input logic clk_i,
    input logic rst_i,
    input logic btn_test_i,

    output logic tick_1khz_o,   // refreshing display / accelerating ticks
    output logic tick_1hz_o,    // incrementing time / blinking dot
    output logic blink_dot_o
);

logic [$clog2(CYCLES_1KHZ)-1:0] cnt_1khz_q, cnt_1khz_d;
logic clk_en_1khz;
logic [$clog2(TICKS_1HZ)-1:0] cnt_1hz_q, cnt_1hz_d;
logic dot_q, dot_d;

always_ff @(posedge clk_i, posedge rst_i) begin 
    if(rst_i) begin
        cnt_1khz_q <= '0;
        cnt_1hz_q <= '0;
        dot_q <= 1'b0;
    end else begin
        cnt_1khz_q <= cnt_1khz_d;
        cnt_1hz_q <= cnt_1hz_d;
        dot_q <= dot_d;
    end
end

always_comb begin
    cnt_1khz_d = cnt_1khz_q;
    cnt_1hz_d = cnt_1hz_q;
    dot_d = dot_q;
    clk_en_1khz = 1'b0;

    if(cnt_1khz_q == CYCLES_1KHZ - 1) begin
        cnt_1khz_d = '0;
        clk_en_1khz = 1'b1;
    end else cnt_1khz_d = cnt_1khz_q + 1'b1;

    if(clk_en_1khz) begin
        if(cnt_1hz_q == TICKS_1HZ - 1) begin
            cnt_1hz_d = '0;
            dot_d = 1'b1;
        end else begin
            cnt_1hz_d = cnt_1hz_q + 1'b1;
            if(cnt_1hz_q == (TICKS_1HZ / 2) - 1) dot_d = 1'b0;
        end
    end

    tick_1khz_o = clk_en_1khz;
    blink_dot_o = dot_q;
    tick_1hz_o = btn_test_i ? clk_en_1khz : (clk_en_1khz && (cnt_1hz_q == TICKS_1HZ - 1));
end

endmodule 
