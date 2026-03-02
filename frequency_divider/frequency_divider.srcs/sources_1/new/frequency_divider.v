`timescale 1ns / 1ps

module frequency_divider #(
    parameter N = 100000000
)(
    input wire clk_in,
    input wire rst,
    output wire clk_out
);

    reg [31:0] counter;
    
    always @(posedge clk_in or posedge rst) begin
        if (rst == 1'b1) begin
        counter <= 0;
       end else begin
           if (counter == N - 1) begin
               counter <= 0;
           end else begin
               counter <= counter + 1;
           end
       end
   end
    
   assign clk_out = (counter < (N/2)) ? 1'b1 : 1'b0;
   
endmodule
