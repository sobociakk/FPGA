`timescale 1ns / 1ps

module frequency_divider_tb;

    reg tb_clk_in;    
    reg tb_rst;       
    
    wire tb_clk_out_4; 
    wire tb_clk_out_5; 

    
    frequency_divider #(
        .N(4)
    ) uut_even (
        .clk_in(tb_clk_in),
        .rst(tb_rst),
        .clk_out(tb_clk_out_4)
    );
    
    frequency_divider #(
        .N(5)
    ) uut_odd (
        .clk_in(tb_clk_in),
        .rst(tb_rst),
        .clk_out(tb_clk_out_5)
    );

    
    always begin
        #5 tb_clk_in = ~tb_clk_in; 
    end

    initial begin
    
        $monitor("Czas: %0t ns | Zegar: %b | N=4 Wyj: %b (Licznik: %0d) | N=5 Wyj: %b (Licznik: %0d)", 
         $time, tb_clk_in, tb_clk_out_4, uut_even.counter, tb_clk_out_5, uut_odd.counter);
        
        tb_clk_in = 1'b0;
        tb_rst = 1'b1; 
        
        #15; 
        
        tb_rst = 1'b0;
        
        #150;
        
        $finish;
    end

endmodule