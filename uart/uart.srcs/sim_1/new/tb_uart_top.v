`timescale 1ns / 1ps

module tb_uart_txrx;

    parameter DBITS = 8;
    parameter SB_TICK = 16;

    reg clk;
    reg rst;
    reg tx_start;
    reg [DBITS-1:0] data_in;

    wire tx_done;
    wire tx;               
    wire data_ready;       
    wire [DBITS-1:0] data_out; 

    reg sample_tick;
    reg [2:0] tick_counter;

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

    uart_rx #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK)
    ) rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx),           
        .sample_tick(sample_tick),
        .data_ready(data_ready),
        .data_out(data_out)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    always @(posedge clk) begin
        if (rst) begin
            tick_counter <= 0;
            sample_tick <= 0;
        end else begin
            if (tick_counter == 4) begin 
                sample_tick <= 1'b1;
                tick_counter <= 0;
            end else begin
                sample_tick <= 1'b0;
                tick_counter <= tick_counter + 1;
            end
        end
    end

    task send_and_check;
        input [DBITS-1:0] test_data;
        begin
            @(posedge clk);
            data_in <= test_data;
            tx_start <= 1;  
            @(posedge clk);      
            tx_start <= 0;

            wait(data_ready == 1'b1);
            
            if (data_out === test_data)
                $display("[PASS] Transmitted: 8'h%h | Received: 8'h%h", test_data, data_out);
            else
                $display("[FAIL] Error! Waited: 8'h%h | Received: 8'h%h", test_data, data_out);
            
            wait(tx_done == 1'b1);
            
            repeat(5) @(posedge clk);
        end
    endtask

    integer i; 

    initial begin
        rst = 1;
        tx_start = 0;
        data_in = 0;
        
        repeat(20) @(posedge clk);
        rst = 0;
        repeat(20) @(posedge clk);

        $display("========================================");
        $display("START SIMULATION");
        $display("========================================");
        $display("\n--- Testy Pojedynczych Bajtow ---");
        send_and_check(8'h95);
        send_and_check(8'h76);
        send_and_check(8'hAA); 
        send_and_check(8'h55); 

        $display("\n--- Test - 10 random bytes ---");
        for (i = 0; i < 10; i = i + 1) begin
            send_and_check($random % 256); 
        end

        $display("\n========================================");
        $display(" SIMULATION COMPLETED");
        $display("========================================");
        
        #500;
        $finish;
    end

endmodule