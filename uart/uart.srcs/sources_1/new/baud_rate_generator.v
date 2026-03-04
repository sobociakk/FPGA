`timescale 1ns / 1ps

module baud_rate_generator #(   // 9600 baud    M = fclk / Bd * 16
    parameter N = 10,           // number of counter bits
              M = 651           // counter limit value
    )(
        input clk,
        input rst,

        output tick
    );

reg [N-1:0] counter;
wire [N-1:0] next;

always @(posedge clk, posedge rst)
    if(rst)
        counter <= 0;
    else
        counter <= next;

// next counter value logic
assign next = (counter == (M-1)) ? 0 : counter + 1;

//output logic
assign tick = (counter == (M-1)) ? 1'b1 : 1'b0;

endmodule
