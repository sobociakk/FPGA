`timescale 1ns / 1ps

module rtc_core(
    input logic clk_i,
    input logic rst_i,
    input logic tick_1hz_i,
    input logic btn_min_tick_i,
    input logic btn_hr_tick_i,

    output logic [4:0] hr_o,
    output logic [5:0] min_o,
    output logic [5:0] sec_o
);

logic [4:0] hr_q, hr_d;
logic [5:0] min_q, min_d;
logic [5:0] sec_q, sec_d;

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        hr_q <= '0;
        min_q <= '0;
        sec_q <= '0;
    end else begin
        hr_q <= hr_d;
        min_q <= min_d;
        sec_q <= sec_d;
    end
end

assign hr_o = hr_q;
assign min_o = min_q;
assign sec_o = sec_q;

always_comb begin
    hr_d = hr_q;
    min_d = min_q;
    sec_d = sec_q;

    if(tick_1hz_i) begin
        if(sec_q == 59) begin
            sec_d = '0;
            if(min_q == 59) begin
                min_d = '0;
                if(hr_q == 23) hr_d = '0;
                else hr_d = hr_q + 1'b1;
            end else min_d = min_q + 1'b1;
        end else sec_d = sec_q + 1'b1;
    end

    if(btn_min_tick_i) begin
        if(min_q == 59) min_d = '0;
        else min_d = min_q + 1'b1;
        sec_d = '0;
    end
    if(btn_hr_tick_i) begin
        if(hr_q == 23) hr_d = '0;
        else hr_d = hr_q + 1'b1;
    end
end

endmodule
