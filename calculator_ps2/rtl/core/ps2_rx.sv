`timescale 1ns / 1ps

module ps2_rx (
    input logic clk_i,
    input logic rst_i,      
    input logic ps2_clk,
    input logic ps2_data,
    
    output logic rx_done_tick,
    output logic [7:0] rx_data
);

    logic [1:0] ps2c_sync_q;
    logic [1:0] ps2d_sync_q;
    
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            ps2c_sync_q <= '0;
            ps2d_sync_q <= '0;
        end else begin
            ps2c_sync_q <= {ps2c_sync_q[0], ps2_clk};
            ps2d_sync_q <= {ps2d_sync_q[0], ps2_data};
        end
    end

    logic fall_edge;
    assign fall_edge = ps2c_sync_q[1] & ~ps2c_sync_q[0];

    typedef enum logic {
        IDLE = 1'b0,
        RX = 1'b1
    } state_e;

    state_e state_q, state_d;
    logic [3:0] bit_cnt_q, bit_cnt_d; 
    logic [7:0] rx_data_q, rx_data_d;
    
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            state_q <= IDLE;
            bit_cnt_q <= '0;
            rx_data_q <= '0;
        end else begin
            state_q <= state_d;
            bit_cnt_q <= bit_cnt_d;
            rx_data_q <= rx_data_d;
        end
    end

    always_comb begin
        state_d = state_q;
        bit_cnt_d = bit_cnt_q;
        rx_data_d = rx_data_q;
        rx_done_tick = 1'b0;

        if (fall_edge) begin
            case (state_q)
                IDLE: begin
                    if (ps2d_sync_q[1] == 1'b0) begin
                        state_d = RX;
                        bit_cnt_d = '0;
                    end
                end

                RX: begin
                    if (bit_cnt_q < 4'd8) begin
                        rx_data_d = {ps2d_sync_q[1], rx_data_q[7:1]};
                        bit_cnt_d = bit_cnt_q + 1'b1;
                    end else if (bit_cnt_q == 4'd8) begin
                        bit_cnt_d = bit_cnt_q + 1'b1;
                    end else begin
                        state_d = IDLE;
                        rx_done_tick = 1'b1;
                    end
                end
                
                default: state_d = IDLE;
            endcase
        end
    end

    assign rx_data = rx_data_q;

endmodule
