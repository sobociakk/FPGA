// Setup for 9600 Bd with 100MHz 
// 9600 * 16 = 153,600
// 100 * 10^6 / 153,600 = ~651     (counter limit M)
// log2(651) = 10                  (counter limit N)

`timescale 1ns / 1ps

module baud_rate_gen #(
    parameter int CLK_FREQ = 100000000, 
                  BAUD_RATE = 9600
    )(
        input logic clk_i,
        input logic rst_ni,

        output logic tick_o
    );

    localparam int MAX_COUNT = CLK_FREQ / BAUD_RATE;

    int unsigned counter_q, counter_d;

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(!rst_ni) begin 
            counter_q <= '0;
        end else begin 
            counter_q <= counter_d;
        end
    end

    always_comb begin
        counter_d = counter_q;
        tick_o = 1'b0;
        if(counter_q == MAX_COUNT - 1) begin
            counter_d = 0;
            tick_o = 1'b1;
        end else begin 
            counter_d = counter_q + 1'b1;
        end
    end

endmodule
