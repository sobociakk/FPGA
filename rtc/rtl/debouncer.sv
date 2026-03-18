`timescale 1ns / 1ps

module debouncer #(
    parameter int DEBOUNCE_CYCLES = 5_000_000    // 50ms -> 100Mhz * 0,05
)(
    input logic clk_i,
    input logic rst_i,
    input logic btn_async_i,  

    output logic btn_tick_o // filtered signal 
);

logic [$clog2(DEBOUNCE_CYCLES)-1:0] cnt_q, cnt_d;
logic state_prev_q, state_q, state_d;
logic [1:0] btn_sync_q;

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        cnt_q <= '0;
        state_q <= 1'b0;
        state_prev_q <= 1'b0;
        btn_sync_q <= 1'b0;
    end else begin
        cnt_q <= cnt_d;
        state_q <= state_d;
        state_prev_q <= state_q;
        btn_sync_q[0] <= btn_async_i;
        btn_sync_q[1] <= btn_sync_q[0];
    end
end

always_comb begin 
    cnt_d = cnt_q;
    state_d = state_q;

    if(btn_sync_q[1] != state_q) begin  // possible bouncing 
        cnt_d = cnt_q + 1'b1;

        if(cnt_q >= DEBOUNCE_CYCLES - 1) begin
            state_d = btn_sync_q[1];
            cnt_d = '0;
        end
    end else cnt_d = '0;
end

assign btn_tick_o = (state_q == 1'b1) && (state_prev_q == 1'b0);

endmodule
