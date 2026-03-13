`timescale 1ns / 1ps

module tb_uart;

    parameter DBITS = 8;
    parameter SB_TICK = 16;
    parameter BR_LIMIT = 651;
    parameter BR_BITS = 10;
    parameter FIFO_EXP = 2;

    reg clk;
    reg rst;
    reg read_uart;
    reg write_uart;
    reg [DBITS-1:0] write_data;
    
    wire rx_full;
    wire rx_empty;
    wire tx_full;
    wire [DBITS-1:0] read_data;
    wire tx;
    wire rx;

    assign rx = tx; 

    uart_top #(
        .DBITS(DBITS),
        .SB_TICK(SB_TICK),
        .BR_LIMIT(BR_LIMIT),
        .BR_BITS(BR_BITS),
        .FIFO_EXP(FIFO_EXP)
    ) dut (
        .clk(clk),
        .rst(rst),
        .read_uart(read_uart),
        .write_uart(write_uart),
        .rx(rx),
        .write_data(write_data),
        .rx_full(rx_full),
        .rx_empty(rx_empty),
        .tx_full(tx_full),
        .tx(tx),
        .read_data(read_data)
    );

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    task send_and_check;
        input [DBITS-1:0] test_data;
        begin
            @(posedge clk);
            write_data = test_data;
            write_uart = 1'b1;
            @(posedge clk);
            write_uart = 1'b0; 

            wait(rx_empty == 1'b0);
            
            if (read_data === test_data)
                $display("[PASS] Transmitted: 8'h%h | Received: 8'h%h", test_data, read_data);
            else
                $display("[FAIL] Error! Transmitted: 8'h%h | Received: 8'h%h", test_data, read_data);
            
            @(posedge clk);
            read_uart = 1'b1;
            @(posedge clk);
            read_uart = 1'b0;
            
            repeat(5) @(posedge clk);
        end
    endtask

    integer i; 

    initial begin
        rst = 1;
        read_uart = 0;
        write_uart = 0;
        write_data = 0;
        
        repeat(20) @(posedge clk);
        rst = 0;
        repeat(20) @(posedge clk);

        $display("========================================");
        $display("START SIMULATION (TOP LEVEL LOOPBACK)");
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