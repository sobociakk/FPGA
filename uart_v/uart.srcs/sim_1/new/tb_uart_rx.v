`timescale 1ns / 1ps

module tb_uart_rx;

    parameter DBITS = 8;
    parameter SB_TICK = 16;

    reg clk;
    reg rst;
    reg tx_start;
    reg sample_tick;
    reg [DBITS-1:0] data_in;

    wire tx_done;
    wire tx;               // Sygnał łączący nadajnik z odbiornikiem
    wire data_ready;       // Sygnał wyjściowy z odbiornika
    wire [DBITS-1:0] data_out; // Odebrane dane

    // 1. Instancja Nadajnika (UUT - Transmitter)
    uart_tx #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
    ) tx_inst (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .sample_tick(sample_tick),
        .data_in(data_in),
        .tx_done(tx_done),
        .tx(tx)
    );

    // 2. Instancja Odbiornika (UUT - Receiver)
    uart_rx #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
    ) rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx),           // Podłączamy tx nadajnika do rx odbiornika
        .sample_tick(sample_tick),
        .data_ready(data_ready),
        .data_out(data_out)
    );

    // Generacja Zegara (100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Generacja Sample Tick (oversampling x16)
    initial begin
        sample_tick = 0;
        forever begin
            #40;              
            sample_tick = 1;  
            #10;            
            sample_tick = 0;  
        end
    end

    // Scenariusz Testowy
    initial begin
        // Inicjalizacja
        rst = 1;
        tx_start = 0;
        data_in = 0;
        #30;
        rst = 0;
        #30;

        // TEST 1: Wysyłanie 8'h95
        $display("--- TEST 1: Sending 8'h95 ---");
        data_in = 8'h95;
        @(posedge clk);      
        tx_start = 1;  
        @(posedge clk);      
        tx_start = 0;

        // Czekamy na sygnał gotowości z Odbiornika
        wait(data_ready == 1'b1);
        if (data_out == 8'h95)
            $display("SUCCESS: Received 8'h%h", data_out);
        else
            $display("ERROR: Expected 8'h95, received 8'h%h", data_out);
        
        #200; // Krótka przerwa

        // TEST 2: Wysyłanie 8'h76
        $display("--- TEST 2: Sending 8'h76 ---");
        data_in = 8'h76;
        @(posedge clk);      
        tx_start = 1;  
        @(posedge clk);      
        tx_start = 0;

        wait(data_ready == 1'b1);
        if (data_out == 8'h76)
            $display("SUCCESS: Received 8'h%h", data_out);
        else
            $display("ERROR: Expected 8'h76, received 8'h%h", data_out);

        #500;
        $display("Simulation completed.");
        $finish;
    end

endmodule