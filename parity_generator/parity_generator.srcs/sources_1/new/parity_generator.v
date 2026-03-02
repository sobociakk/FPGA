`timescale 1ns / 1ps

module parity_generator(
    input wire [7:0] SW,
    output wire [7:0] AN,
    output wire [6:0] SEG
    );

    wire is_odd;

    assign is_odd = ^SW;

    assign AN = 8'b11111110;

    assign SEG = is_odd ? 7'b1000000 : 7'b0000110;
    
endmodule
