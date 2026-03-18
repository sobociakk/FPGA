`timescale 1ns / 1ps

module debouncer #(
    parameter int DEBOUNCE_TIME = 5_000_000    // 50ms -> 100Mhz * 0,05
)(
    input logic clk_i,
    input logic rst_i,
    input logic btn_i,

    output logic btn_tick_o
);

logic [$clog2(DEBOUNCE_TIME)-1:0] counter_q, counter_d;
logic state_q, state_d;
logic state_prev_q;

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        counter_q <= '0;
        state_q <= 1'b0;
        state_prev_q <= state_q; // Tu też lepiej dać twarde '0' zamiast state_q
    end else begin
        counter_q <= counter_d;
        state_q <= state_d;
        state_prev_q <= state_q; // Zapisanie poprzedniego stanu do detekcji zbocza
    end
end

always_comb begin 
    counter_d = counter_q;
    state_d = state_q;

    if(btn_i != state_q) begin
        counter_d = counter_q + 1'b1;

        if(counter_q == DEBOUNCE_TIME) begin
            state_d = btn_i;
            counter_d = '0;
        end
    end else begin
        counter_d = '0;
    end
end

assign btn_tick_o = (state_q == 1'b1) && (state_prev_q == 1'b0);

endmodule
