`timescale 1ns / 1ps

module tb_uart_tx;

    parameter DBITS = 8;
    parameter SB_TICK = 16;

    reg clk;
    reg rst;
    reg tx_start;
    reg sample_tick;
    reg [DBITS-1:0] data_in;

    
    wire tx_done;
    wire tx;

    uart_tx #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
    ) uut (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .sample_tick(sample_tick),
        .data_in(data_in),
        .tx_done(tx_done),
        .tx(tx)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        sample_tick = 0;
        forever begin
            #40;              
            sample_tick = 1;  
            #10;            
            sample_tick = 0;  
        end
    end

    initial begin
        rst = 1;
        tx_start = 0;
        data_in = 0;

        #30;
        rst = 0;
        #30;

        $display("TEST 1: Sending 8'h95");    // 10010101
        data_in = 8'h95;
        @(posedge clk);      
        tx_start = 1;  
        @(posedge clk);      
        tx_start = 0;

        wait(tx_done == 1'b1);
        $display("TEST 1 finished!");
        #100; 

        $display("TEST 2: Sending 8'h76");    // 01110110
        data_in = 8'h76;
        @(posedge clk);      
        tx_start = 1;  
        @(posedge clk);      
        tx_start = 0;

        wait(tx_done == 1'b1);
        $display("TEST 2 finished!");
        #100;

        $display("Symulation completed.");
        $finish;
    end

endmodule