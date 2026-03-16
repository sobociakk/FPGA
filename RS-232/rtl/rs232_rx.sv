`timescale 1ns / 1ps

module rs232_rx #(
    parameter int SB_TICK = 16
) (
    input logic clk_i,
    input logic rst_i,
    input logic baud_tick_i,
    input logic rx_i,
    input logic ready_i,

    output logic [7:0] data_o,
    output logic valid_o
);

typedef enum logic [1:0] { 
    IDLE = 2'b00,
    START = 2'b01, 
    DATA = 2'b10,
    STOP = 2'b11
} state_e;

state_e state_q, next_state_d;

logic [7:0] rx_data_q, rx_data_d;
logic [2:0] bit_cnt_q, bit_cnt_d;
logic [3:0] tick_cnt_q, tick_cnt_d;
logic valid_q, valid_d;
logic rx_sync_q, rx_meta_q;

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        rx_meta_q <= 1'b1;
        rx_sync_q <= 1'b1;

        rx_data_q <= '0;
        bit_cnt_q <= '0;
        tick_cnt_q <= '0;
        valid_q <= 1'b0;
        state_q <= IDLE;
    end else begin
        rx_meta_q <= rx_i;
        rx_sync_q <= rx_meta_q;

        tick_cnt_q <= tick_cnt_d;
        rx_data_q <= rx_data_d;
        bit_cnt_q <= bit_cnt_d;
        valid_q <= valid_d;
        state_q <= next_state_d;
    end
end

always_comb begin 
    tick_cnt_d = tick_cnt_q;
    rx_data_d = rx_data_q;
    bit_cnt_d = bit_cnt_q;
    next_state_d = state_q;
    valid_d = valid_q;

    if(valid_q == 1'b1 && ready_i == 1'b1) begin
        valid_d = 1'b0;
    end
    

    case (state_q)
        IDLE : begin
            if(rx_sync_q == 1'b0) begin
                tick_cnt_d = '0;
                next_state_d = START;
            end
        end 

        START : begin
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

        DATA : begin
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

        STOP : begin
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

assign data_o = rx_data_q;
assign valid_o = valid_q;

endmodule