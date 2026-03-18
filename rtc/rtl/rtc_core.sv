`timescale 1ns / 1ps

module rtc_core(
    input logic clk_i,
    input logic rst_i,
    input logic tick_1hz_i,
    input logic btn_min_tick_i,
    input logic btn_hr_tick_i,

    output logic [3:0] hr_t_o;  // tens
    output logic [3:0] hr_u_o;  // units
    output logic [3:0] min_t_o;
    output logic [3:0] min_u_o;
    output logic [3:0] sec_t_o;
    output logic [3:0] sec_u_o;
);

logic [3:0] hr_t_q, hr_t_d;
logic [3:0] hr_u_q, hr_u_d;
logic [3:0] min_t_q, min_t_d;
logic [3:0] min_u_q, min_u_d;
logic [3:0] sec_t_q, sec_t_d;
logic [3:0] sec_u_q, sec_u_d;

logic en_sec_t;
logic en_min_t, en_min_u;
logic en_hr_u;

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        hr_t_q <= '0;
        hr_u_q <= '0;
        min_t_q <= '0;
        min_u_q <= '0;
        sec_t_q <= '0;
        sec_u_q <= '0;
    end else begin
        hr_t_q <= hr_t_d;
        hr_u_q <= ht_u_d;
        min_t_q <= min_t_d;
        min_u_q <= min_u_d;
        sec_t_q <= sec_t_d;
        sec_u_q <= sec_u_d;
    end
end

assign hr_t_o = hr_t_q;
assign hr_u_o = ht_u_q;
assign min_t_o = min_t_q;
assign min_u_o = min_u_q;
assign sec_t_o = sec_t_q;
assign sec_u_o = sec_u_q;

always_comb begin
    hr_t_d = hr_t_q;
    hr_u_d = ht_u_q;
    min_t_d = min_t_q;
    min_u_d = min_u_q;
    sec_t_d = sec_t_q;
    sec_u_d = sec_u_q;

    en_sec_t = tick_1hz_i && (sec_u_q == 4'd9);
    en_min_u = en_sec_t && (sec_t_q == 4'd5);
    en_min_t = en_min_u && (min_u_q == 4'd9);
    en_hr_u = en_min_t && (min_t_q == 4'd5);

    if(tick_1hz_i) begin
        if(sec_u_q == 4'd9) sec_u_d = '0;
        else sec_u_d = sec_u_q + 1'b1;
    end

    if(en_sec_t) begin
        if(sec_t_q == 4'd5) sec_t_d = '0;
        else sec_t_d = sec_t_q + 1'b1;
    end

    if(btn_min_tick_i || en_min_u) begin
        if(min_u_q == 4'd9) min_u_d = '0;
        else min_u_d = min_u_q + 1'b1;
    end

    if(btn_min_tick_i || en_min_t) begin
        if(min_t_q == 4'd5) min_t_d = '0;
        else min_t_d = min_t_q + 1'b1;
    end

    if(btn_hr_tick_i || en_hr_u) begin
        if(hr_t_q == 4'd2 && hr_u_q == 4'd3) begin
            hr_t_d = '0;
            hr_u_d = '0;
        end else if(hr_u_q == 4'd9) begin
            hr_t_d = hr_t_q + 1'b1;
            hr_u_d = '0;
        end else hr_u_d = hr_u_q + 1'b1;
    end

    if(btn_min_tick_i) begin
        sec_t_d = '0;
        sec_u_d = '0;
    end
end

endmodule
