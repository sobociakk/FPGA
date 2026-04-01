`timescale 1ns / 1ps

module display #(parameter CYCLES_1KHZ = 100_000)(
    input logic clk_i,
    input logic rst_i,       
    input logic [15:0] display_val,
    
    output logic [3:0] led7_an_o,   
    output logic [6:0] led7_seg_o
);

    logic [$clog2(CYCLES_1KHZ)-1:0] cnt_1khz_q, cnt_1khz_d;
    logic clk_en_1khz;
    logic [1:0] digit_sel_q, digit_sel_d;

    always_ff @(posedge clk_i, posedge rst_i) begin
        if (rst_i) begin
            digit_sel_q <= '0;
            cnt_1khz_q <= '0;
        end else begin
            cnt_1khz_q <= cnt_1khz_d;
            digit_sel_q <= digit_sel_d;
        end
    end

    always_comb begin
        cnt_1khz_d = cnt_1khz_q + 1'b1;
        clk_en_1khz = 1'b0;

        if (cnt_1khz_q == CYCLES_1KHZ - 1) begin
        cnt_1khz_d = '0;
        clk_en_1khz = 1'b1;
        end

        digit_sel_d = digit_sel_q;
        if (clk_en_1khz) digit_sel_d = digit_sel_q + 1'b1;
    end

    logic [3:0] current_bcd;
    logic [3:0] an_comb;
    logic [6:0] seg_comb;

    always_comb begin
        an_comb = 4'b1111; 
        current_bcd = 4'b0000;

        case (digit_sel_q)
            2'd0: begin 
                an_comb = 4'b1110; 
                current_bcd = display_val[3:0];
            end
            2'd1: begin 
                an_comb = 4'b1101; 
                current_bcd = display_val[7:4];
            end
            2'd2: begin 
                an_comb = 4'b1011; 
                current_bcd = display_val[11:8];
            end
            2'd3: begin
                an_comb = 4'b0111; 
                current_bcd = display_val[15:12];
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
        end else begin
            led7_an_o <= an_comb;
            led7_seg_o <= seg_comb;
        end
    end
endmodule
