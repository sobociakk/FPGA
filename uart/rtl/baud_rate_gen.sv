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
        input logic enable_i,   // gen runs only when enabled

        output logic tick_o
    );

    localparam int MAX_COUNT = CLK_FREQ / BAUD_RATE;
    int unsigned cycle_count;

    always_ff @(posedge clk_i, negedge rst_ni) begin
        if(!rst_ni) begin
            cycle_count <= 0;
            tick_o <= 1'b0;
        end else if(!enable_i) begin
            cycle_count <= 0;
            tick_o <= 1'b0;
        end else begin
            cycle_count <= cycle_count + 1;
            tick_o <= 1'b0;

            if(cycle_count >= MAX_COUNT - 1) begin
                tick_o <= 1'b1;
                cycle_count <= 0;
            end
        end
    end 

endmodule
