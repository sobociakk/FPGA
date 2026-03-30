`timescale 1ns / 1ps

module ps2_rx #(parameter CLK_FREQ = 100_000_000)(
    input logic clk_i,
    input logic rst_i,      
    input logic ps2_clk,
    input logic ps2_data,
    
    output logic rx_done_tick,
    output logic [7:0] rx_data
);

    localparam FILTER_MAX = (CLK_FREQ / 1_000_000) * 2;     // 2us
    localparam TIMEOUT_MAX = (CLK_FREQ / 1_000) * 3 / 2;    // 1.5ms

    logic [1:0] ps2c_sync_q;
    logic [1:0] ps2d_sync_q;
    
    always_ff @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            ps2c_sync_q <= '0;
            ps2d_sync_q <= '0;
        end else begin
            ps2c_sync_q <= {ps2c_sync_q[0], ps2_clk};
            ps2d_sync_q <= {ps2d_sync_q[0], ps2_data};
        end
    end

     logic [7:0] filter_cnt;    
     logic filter_clk_q, filter_clk_dly;

     always_ff @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            filter_cnt <= '0;
            filter_clk_q <= 1'b1;
            filter_clk_dly <= 1'b1;
        end else begin
            filter_clk_dly <= filter_clk_q;
            if(ps2c_sync_q[1] == filter_clk_q) filter_cnt <= '0;
            else begin
                filter_cnt <= filter_cnt + 1'b1;
                if(filter_cnt == FILTER_MAX) begin
                    filter_clk_q <= ps2c_sync_q[1];
                    filter_cnt <= '0;
                end
            end
        end
     end

    logic fall_edge;
    //assign fall_edge = ps2c_sync_q[1] & ~ps2c_sync_q[0];
    assign fall_edge = filter_clk_dly & ~filter_clk_q;

    typedef enum logic {
        IDLE = 1'b0,
        RX = 1'b1
    } state_e;

    state_e state_q, state_d;
    logic [3:0] bit_cnt_q, bit_cnt_d; 
    logic [7:0] rx_data_q, rx_data_d;
    logic parity_q, parity_d;
    logic [$clog2(TIMEOUT_MAX)-1:0] timeout_cnt_q, timeout_cnt_d;
    
    always_ff @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            state_q <= IDLE;
            bit_cnt_q <= '0;
            rx_data_q <= '0;
            parity_q <= '0;
            timeout_cnt_q <= '0;
        end else begin
            state_q <= state_d;
            bit_cnt_q <= bit_cnt_d;
            rx_data_q <= rx_data_d;
            parity_q <= parity_d;
            timeout_cnt_q <= timeout_cnt_d;
        end
    end

    always_comb begin
        state_d = state_q;
        bit_cnt_d = bit_cnt_q;
        rx_data_d = rx_data_q;
        parity_d = parity_q;
        timeout_cnt_d = timeout_cnt_q;
        rx_done_tick = 1'b0;

        if(state_q == RX) begin
            timeout_cnt_d = timeout_cnt_q + 1'b1;
            if(timeout_cnt_q >= TIMEOUT_MAX) state_d = IDLE;
        end

        if(fall_edge) begin
            timeout_cnt_d = '0;
            case(state_q)
                IDLE: begin
                    if(ps2d_sync_q[1] == 1'b0) begin
                        state_d = RX;
                        bit_cnt_d = '0;
                        parity_d = '0;
                    end
                end

                RX: begin
                    if(bit_cnt_q < 4'd8) begin
                        rx_data_d = {ps2d_sync_q[1], rx_data_q[7:1]};
                        bit_cnt_d = bit_cnt_q + 1'b1;
                        parity_d = parity_q ^ ps2d_sync_q[1];
                    end else if (bit_cnt_q == 4'd8) begin
                        if(ps2d_sync_q[1] == ~parity_q) bit_cnt_d = bit_cnt_q + 1'b1;   // odd parity
                        else state_d = IDLE;
                    end else if(bit_cnt_q == 4'd9) begin
                        if(ps2d_sync_q[1] == 1'b1) rx_done_tick = 1'b1;
                        state_d = IDLE;
                    end
                end
                
                default: state_d = IDLE;
            endcase
        end
    end

    assign rx_data = rx_data_q;
endmodule
