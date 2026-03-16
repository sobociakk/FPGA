`timescale 1ns / 1ps

module baud_rate_gen #(
    parameter int CLK_FREQ = 100_000_000,
                  BAUD_RATE = 9600
) (
    input logic clk_i,
    input logic rst_i,
    input logic enable_i,

    output logic tick_o
);

localparam int MAX_FREQ = CLK_FREQ / BAUD_RATE;
int unsigned cycle_count;

always_ff @(posedge clk_i, posedge rst_i) begin
    if(rst_i) begin
        cycle_count <= 0;
        tick_o <= 1'b0;
    end else if(!enable_i) begin
        cycle_count <= 0;
        tick_o <= 1'b0;
    end else begin
        cycle_count <= cycle_count + 1;
        tick_o <= 1'b0;
        if(cycle_count >= MAX_FREQ - 1) begin 
            tick_o <= 1'b1;
            cycle_count <= 0;
        end 
    end
end

endmodule
