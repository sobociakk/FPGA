`timescale 1ns / 1ps

module uart_tx(
    uart_tx_if.mac_mp bus_i, 
    
    input logic clk_i, 
    input logic rst_ni, 
    input logic baud_tick_i,

    output logic tx_o
    );

    logic [7:0] tx_data_d, tx_data_q;  // data to send
    logic [2:0] bit_cnt_d, bit_cnt_q;  // data counter

    // FSM
    typedef enum logic [1:0] { 
        IDLE = 2'b00,
        START = 2'b01,
        DATA = 2'b10,
        STOP = 2'b11
    } state_e;

    state_e state_q, next_state_d;

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(!rst_ni) begin
            tx_data_q <= '0;
            bit_cnt_q <= '0;
            state_q <= IDLE;
        end else begin
            state_q <= next_state_d;
            tx_data_q <= tx_data_d;
            bit_cnt_q <= bit_cnt_d;
        end
    end

    always_comb begin
        next_state_d = state_q;
        tx_data_d = tx_data_q;
        bit_cnt_d = bit_cnt_q;
        bus_i.ready = (state_q == IDLE);
        tx_o = 1'b1;

        case(state_q)
            IDLE: begin
                if(bus_i.valid == 1'b1 && bus_i.ready == 1'b1) begin
                    tx_data_d = bus_i.data;
                    bit_cnt_d = '0;
                    next_state_d = START;
                end
            end

            START: begin
                tx_o = 1'b0;
                if(baud_tick_i == 1'b1) begin
                    next_state_d = DATA;
                end
            end

            DATA: begin
                tx_o = tx_data_q[0];
                if(baud_tick_i == 1'b1) begin
                    tx_data_d = tx_data_q >> 1;
                    if(bit_cnt_q == 3'd7) begin
                        next_state_d = STOP;
                    end else begin
                        bit_cnt_d = bit_cnt_q + 1'b1;
                    end
                end
            end

            STOP: begin
                if(baud_tick_i == 1'b1) begin
                    next_state_d = IDLE;
                end
            end

        default: next_state_d = IDLE;

        endcase
    end
    
endmodule
