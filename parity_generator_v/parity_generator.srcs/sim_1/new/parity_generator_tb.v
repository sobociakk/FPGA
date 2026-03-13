`timescale 1ns / 1ps

module parity_generator_tb;

    reg [7:0] tb_SW;
    
    wire [7:0] tb_AN;
    wire [6:0] tb_SEG;
  
  parity_generator uut(
    .SW(tb_SW),
    .AN(tb_AN),
    .SEG(tb_SEG)
  );
  
  initial begin
  
    $monitor("Czas: %0t | SW: %b | AN: %b | SEG: %b", $time, tb_SW, tb_AN, tb_SEG);
    
    tb_SW = 8'b00000000;
    #10
        
    tb_SW = 8'b00000001;
    #10;
        
    tb_SW = 8'b10000001;
    #10;
        
    tb_SW = 8'b10101010;
    #10;
        
    tb_SW = 8'b10101011;
    #10;

    $finish;
 end
endmodule
