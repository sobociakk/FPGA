`timescale 1ns / 1ps

module tb_rs232_top();

    localparam int CLK_FREQ    = 100_000_000;
    localparam int BAUD_RATE   = 9600;
    localparam time BIT_PERIOD = 1s / BAUD_RATE; 

    logic clk = 0;
    logic rst = 1;
    logic rxd = 1;
    logic txd;
    
    int error_count = 0;

    always #5ns clk = ~clk;

    rs232_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk_i(clk),
        .rst_i(rst),
        .RXD_i(rxd),
        .TXD_o(txd)
    );

    task automatic send_uart_char(input [7:0] data);
        rxd = 0; 
        #(BIT_PERIOD);
        for (int i = 0; i < 8; i++) begin
            rxd = data[i]; 
            #(BIT_PERIOD);
        end
        rxd = 1;
        #(BIT_PERIOD);
    endtask

    task automatic verify_uart_char(input [7:0] expected_char);
        logic [7:0] captured_data;
        
        wait(txd == 0);
        
        #(BIT_PERIOD * 1.5);
        
        for (int i = 0; i < 8; i++) begin
            captured_data[i] = txd;
            #(BIT_PERIOD);
        end
        
        if (captured_data === expected_char) begin
            $display("[PASS] Sent: '%c' (0x%h) | Received: '%c' (0x%h)", 
                      expected_char - 8'h20, expected_char - 8'h20, captured_data, captured_data);
        end else begin
            $error("[FAIL] Sent: '%c' (0x%h) | Expected: '%c' (0x%h) | Got: 0x%h", 
                    expected_char - 8'h20, expected_char - 8'h20, expected_char, expected_char, captured_data);
            error_count++;
        end
        
        #(BIT_PERIOD);
    endtask
-
    initial begin
        $display("--------------------------------------------------");
        $display("STARTING FULL ALPHABET RS232 TEST (A-Z)");
        $display("--------------------------------------------------");
        
        rst = 1;
        #200ns;
        rst = 0;
        #1us;

        for (logic [7:0] char = 8'h41; char <= 8'h5A; char++) begin
            fork
                send_uart_char(char);
                verify_uart_char(char + 8'h20); 
            join
            #100us; 
        end

        $display("--------------------------------------------------");
        if (error_count == 0) begin
            $display("TEST RESULT: SUCCESS! All characters processed.");
        end else begin
            $display("TEST RESULT: FAILED with %0d errors.", error_count);
        end
        $display("--------------------------------------------------");
        $finish;
    end

endmodule