`timescale 1ns / 1ps

module display (
    input logic clk_i,
    input logic rst_i,       
    input logic tick_1khz_i,  
    input logic blink_dot_i, 
    input logic [3:0] hr_t_i,  
    input logic [3:0] hr_u_i,  
    input logic [3:0] min_t_i,
    input logic [3:0] min_u_i,
    
    output logic [3:0] led7_an_o,   
    output logic [6:0] led7_seg_o,
    output logic dp_o  
);

logic [1:0] digit_sel_q, digit_sel_d;

always_ff @(posedge clk_i, posedge rst_i) begin
    if (rst_i) digit_sel_q <= '0;
    else digit_sel_q <= digit_sel_d;
end

always_comb begin
    digit_sel_d = digit_sel_q;
    if (tick_1khz_i) digit_sel_d = digit_sel_q + 1'b1;
end

logic [3:0] current_bcd;
logic [3:0] an_comb;
logic [6:0] seg_comb;
logic dp_comb; 

always_comb begin
    an_comb = 4'b1111; 
    current_bcd = 4'b0000;
    dp_comb = 1'b1;    

    case (digit_sel_q)
        2'd0: begin 
            an_comb = 4'b1110; 
            current_bcd = min_u_i;
        end
        2'd1: begin 
            an_comb = 4'b1101; 
            current_bcd = min_t_i;
        end
        2'd2: begin 
            an_comb = 4'b1011; 
            current_bcd = hr_u_i;
            dp_comb = ~blink_dot_i; 
        end
        2'd3: begin
            an_comb = 4'b0111; 
            current_bcd = hr_t_i;
        end
        default: an_comb = 4'b1111;
    endcase
end

always_comb begin
    case (current_bcd)                       
        4'h0: seg_comb = 7'b1000000;
        4'h1: seg_comb = 7'b1111001;
        4'h2: seg_comb = 7'b0100100;
        4'h3: seg_comb = 7'b0110000;
        4'h4: seg_comb = 7'b0011001;
        4'h5: seg_comb = 7'b0010010;
        4'h6: seg_comb = 7'b0000010;
        4'h7: seg_comb = 7'b1111000;
        4'h8: seg_comb = 7'b0000000;
        4'h9: seg_comb = 7'b0010000;
        default: seg_comb = 7'b1111111;
    endcase
end

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        led7_an_o <= 4'b1111;
        led7_seg_o <= 7'b1111111;
        dp_o <= 1'b1;
    end else begin
        led7_an_o <= an_comb;
        led7_seg_o <= seg_comb;
        dp_o <= dp_comb;
    end
end
endmodule
