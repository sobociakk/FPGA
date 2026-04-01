`timescale 1ns / 1ps

module key_decoder(
    input logic clk_i,
    input logic rst_i,
    input logic rx_done_tick,
    input logic [7:0] rx_data,

    output logic key_valid,
    output logic is_digit,
    output logic [3:0] digit_val,
    output logic is_plus,
    output logic is_minus,
    output logic is_equal,
    output logic is_esc
);

    typedef enum logic {NORMAL, BREAK} state_e;
    state_e state_q, state_d;

    always_ff @(posedge clk_i or posedge rst_i) begin
        if(rst_i) state_q <= NORMAL;
        else state_q <= state_d;
    end

    always_comb begin
        state_d = state_q;
        key_valid = 1'b0;
        is_digit = 1'b0;
        digit_val = 4'b0;
        is_plus = 1'b0;
        is_minus = 1'b0;
        is_equal = 1'b0;
        is_esc = 1'b0;

        if(rx_done_tick) begin
            case(state_q) 
                NORMAL: begin
                    if(rx_data == 8'hF0) state_d = BREAK;
                    else begin
                        key_valid = 1'b1;
                        case(rx_data)
                            8'h45: begin is_digit = 1'b1; digit_val = 4'd0; end 
                            8'h16: begin is_digit = 1'b1; digit_val = 4'd1; end 
                            8'h1E: begin is_digit = 1'b1; digit_val = 4'd2; end
                            8'h26: begin is_digit = 1'b1; digit_val = 4'd3; end 
                            8'h25: begin is_digit = 1'b1; digit_val = 4'd4; end 
                            8'h2E: begin is_digit = 1'b1; digit_val = 4'd5; end 
                            8'h36: begin is_digit = 1'b1; digit_val = 4'd6; end 
                            8'h3D: begin is_digit = 1'b1; digit_val = 4'd7; end 
                            8'h3E: begin is_digit = 1'b1; digit_val = 4'd8; end 
                            8'h46: begin is_digit = 1'b1; digit_val = 4'd9; end 
                            8'h79: is_plus = 1'b1; 
                            8'h7B: is_minus = 1'b1; 
                            8'h5A: is_equal = 1'b1; // Enter ('=')
                            8'h76: is_esc = 1'b1; 
                            default: key_valid = 1'b0;
                        endcase
                    end
                end

                BREAK: begin
                    state_d = NORMAL;
                end

                default: state_d = NORMAL;
            endcase
        end
    end

endmodule