`timescale 1ns / 1ps

module uart_rx #(
   parameter int SB_TICK = 16   // oversampling ticks 
)(
    input logic clk_i,
    input logic rst_ni,
    input logic baud_tick_i,
    input logic rx_i,

    uart_rx_if.mac_mp bus_i
);

typedef enum logic [1:0] { 
    IDLE = 2'b00,
    START = 2'b01,
    DATA = 2'b10,
    STOP = 2'b11
} state_e;

state_e state_q, next_state_d;

logic [3:0] tick_cnt_q, tick_cnt_d;
logic [2:0] bit_cnt_q, bit_cnt_d;
logic [7:0] rx_data_q, rx_data_d;
logic valid_q, valid_d;

logic rx_meta_q, rx_sync_q;

always_ff @(posedge clk_i, negedge rst_ni) begin
    if(!rst_ni) begin
        rx_meta_q <= 1'b1;
        rx_sync_q <= 1'b1;
            
        state_q <= IDLE;
        tick_cnt_q <= '0;
        bit_cnt_q <= '0;
        rx_data_q <= '0;
        valid_q <= 1'b0;
    end else begin
        rx_meta_q <= rx_i;
        rx_sync_q <= rx_meta_q;
            
        state_q <= next_state_d;
        tick_cnt_q <= tick_cnt_d;
        bit_cnt_q <= bit_cnt_d;
        rx_data_q <= rx_data_d;
        valid_q <= valid_d;
    end
end

always_comb begin 
    bus_i.valid = valid_q;
    bus_i.data = rx_data_q; 
    tick_cnt_d = tick_cnt_q;
    bit_cnt_d = bit_cnt_q;
    next_state_d = state_q;
    rx_data_d = rx_data_q;
    valid_d = valid_q;

    if(bus_i.ready == 1'b1 && valid_q == 1'b1) begin
        valid_d = 1'b0;
    end

    case(state_q)
        IDLE: begin
            if(rx_sync_q == 1'b0) begin
                tick_cnt_d = '0;
                next_state_d = START;
            end
        end

        START: begin
            if(baud_tick_i == 1'b1) begin
                if(tick_cnt_q == 4'd7) begin
                    if(rx_sync_q == 1'b0) begin 
                        bit_cnt_d = '0;
                        tick_cnt_d = '0;
                        next_state_d = DATA;
                    end
                    if(rx_sync_q == 1'b1) begin
                        next_state_d = IDLE;
                    end
                end else begin 
                    tick_cnt_d = tick_cnt_q + 1'b1;
                end
            end
        end

        DATA: begin
            if(baud_tick_i == 1'b1) begin
                if(tick_cnt_q == 4'd15) begin
                    tick_cnt_d = '0;
                    rx_data_d = {rx_sync_q, rx_data_q[7:1]};
                    if(bit_cnt_q == 3'd7) begin
                        next_state_d = STOP;
                    end else begin
                        bit_cnt_d = bit_cnt_q + 1'b1;
                    end
                end else begin
                    tick_cnt_d = tick_cnt_q + 1'b1;
                end
            end
        end

        STOP: begin
            if(baud_tick_i == 1'b1) begin
                if(tick_cnt_q == 4'd15) begin
                    valid_d = 1'b1;
                    next_state_d = IDLE;
                end else begin
                    tick_cnt_d = tick_cnt_q + 1'b1;
                end
            end
        end

        default: next_state_d = IDLE;
    endcase
end

endmodule