`timescale 1ns / 1ps

module rs232_tx(
    input logic clk_i,
    input logic rst_i,
    input logic baud_tick_i,
    input logic [7:0] data_i,
    input logic valid_i,
    
    output logic ready_o,
    output logic tx_o
);

typedef enum logic [1:0] { 
    IDLE = 2'b00,
    START = 2'b01, 
    DATA = 2'b10,
    STOP = 2'b11
} state_e;

state_e state_q, next_state_d;

logic [7:0] tx_data_q, tx_data_d;
logic [2:0] bit_cnt_q, bit_cnt_d;
logic tx_q, tx_d;

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        tx_data_q <= '0;
        bit_cnt_q <= '0;
        state_q <= IDLE;
        tx_q <= 1'b1;
    end else begin
        tx_data_q <= tx_data_d;
        bit_cnt_q <= bit_cnt_d;
        state_q <= next_state_d;
        tx_q <= tx_d;
    end
end

assign tx_o = tx_q;

always_comb begin 
    tx_data_d = tx_data_q;
    bit_cnt_d = bit_cnt_q;
    next_state_d = state_q;
    tx_d = 1'b1;
    ready_o = (state_q == IDLE);

    case (state_q)
        IDLE : begin
            if(valid_i == 1'b1) begin
                tx_data_d = data_i;
                bit_cnt_d = '0;
                next_state_d = START;
            end
        end 

        START : begin
            tx_d = 1'b0;
            if(baud_tick_i == 1'b1) begin
                next_state_d = DATA;
            end
        end 

        DATA : begin
            tx_d = tx_data_q[0];
            if(baud_tick_i == 1'b1) begin
                tx_data_d = tx_data_q >> 1;
                if(bit_cnt_q == 3'd7) begin 
                    next_state_d = STOP;
                end else begin
                    bit_cnt_d = bit_cnt_q + 1'b1;
                end
            end
        end 

        STOP : begin
            if(baud_tick_i == 1'b1) begin
                next_state_d = IDLE;
            end
        end 

        default: next_state_d = IDLE;
    endcase

end

endmodule
