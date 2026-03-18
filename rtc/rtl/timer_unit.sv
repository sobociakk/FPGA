`timescale 1ns / 1ps

module timer_unit (
    input logic clk_i,
    input logic rst_i,
    input logic btn_test_i,

    output logic tick_1khz_o,
    output logic tick_1hz_o,
    output logic blink_dot_o
);

localparam int CYCLES_1KHZ = 100_000;
logic [$clog2(CYCLES_1KHZ-1):0] cnt_1khz_q, cnt_1khz_d;
logic tick_1khz_interal;

localparam int TICKS_1HZ = 1000;
logic [$clog2(TICKS_1HZ-1):0] cnt_1hz_q, cnt_1hz_d;

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
    tick_1khz_interal = 1'b0;

    if(cnt_1khz_q == CYCLES_1KHZ - 1) begin
        cnt_1khz_d = '0;
        tick_1khz_interal = 1'b1;
    end else cnt_1khz_d = cnt_1khz_q + 1'b1;

    if(tick_1khz_interal) begin
        if(cnt_1hz_q == TICKS_1HZ - 1) begin
            cnt_1hz_d = '0;
            dot_d = 1'b1;
        end else begin
            cnt_1hz_d = cnt_1hz_q + 1'b1;

            if(cnt_1hz_q == (TICKS_1HZ / 2) - 1) dot_d = 1'b0;
        end
    end
end

assign tick_1khz_o = tick_1khz_interal;
assign blink_dot_o = dot_q;
assign tick_1hz_o = btn_test_i ? tick_1khz_interal : (tick_1khz_interal && (cnt_1hz_q == TICKS_1HZ - 1));

endmodule 
