`timescale 1ns / 1ps

module display (
    input logic clk_i,
    input logic rst_i,       
    input logic tick_1khz_i,  
    input logic blink_dot_i, 
    input logic [4:0] hr_i, 
    input logic [5:0] min_i,  
    
    output logic [3:0] led7_an_o,   
    output logic [7:0] led7_seg_o  
);

    logic [3:0] hr_tens, hr_ones;
    logic [3:0] min_tens, min_ones;

    assign hr_tens = hr_i / 10;
    assign hr_ones = hr_i % 10;
    assign min_tens = min_i / 10;
    assign min_ones = min_i % 10;

    logic [1:0] digit_sel_q, digit_sel_d;

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            digit_sel_q <= '0;
        end else begin
            digit_sel_q <= digit_sel_d;
        end
    end

    always_comb begin
        digit_sel_d = digit_sel_q;
        if (tick_1khz_i) begin
            digit_sel_d = digit_sel_q + 1'b1;
        end
    end

    logic [3:0] current_digit_val;
    logic current_dot_val;

    always_comb begin
        led7_an_o = 4'b1111; 
        current_digit_val = 4'b0000;
        current_dot_val = 1'b1;    

        case (digit_sel_q)
            2'd0: begin 
                led7_an_o = 4'b1110; 
                current_digit_val = min_ones;
            end
            2'd1: begin 
                led7_an_o = 4'b1101; 
                current_digit_val = min_tens;
            end
            2'd2: begin 
                led7_an_o = 4'b1011; 
                current_digit_val = hr_ones;
                current_dot_val = ~blink_dot_i; 
            end
            2'd3: begin
                led7_an_o = 4'b0111; 
                current_digit_val = hr_tens;
            end
        endcase
    end

    logic [6:0] seg_out; 

    always_comb begin
        case (current_digit_val)                       
            4'h0: seg_out = 7'b1000000;
            4'h1: seg_out = 7'b1111001;
            4'h2: seg_out = 7'b0100100;
            4'h3: seg_out = 7'b0110000;
            4'h4: seg_out = 7'b0011001;
            4'h5: seg_out = 7'b0010010;
            4'h6: seg_out = 7'b0000010;
            4'h7: seg_out = 7'b1111000;
            4'h8: seg_out = 7'b0000000;
            4'h9: seg_out = 7'b0010000;
            default: seg_out = 7'b1111111;
        endcase
    end

    assign led7_seg_o = {current_dot_val, seg_out};

endmodule
