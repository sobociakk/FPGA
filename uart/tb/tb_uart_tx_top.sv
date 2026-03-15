`timescale 1ns / 1ps

module tb_uart_tx_top;

    localparam int CLK_FREQ = 100_000_000;
    localparam int BAUD_RATE = 10_000_000; 

    logic clk;
    logic rst_n;
    logic tx_serial_out;

    uart_tx_if tx_if();

    uart_tx_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) DUT (
        .bus_i(tx_if.mac_mp),
        .clk_i(clk),
        .rst_ni(rst_n),
        .tx_o(tx_serial_out)
    );

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst_n = 1'b0;
        tx_if.valid = 1'b0;
        tx_if.data = 8'h00;
        
        #20;
        rst_n = 1'b1;
        #20;
        
        $display("========================================");
        $display("[TB] Starting UART TX transmitter test.");
        $display("========================================");
        
        @(posedge clk); 
        tx_if.valid = 1'b1;
        tx_if.data = 8'h55; 
        $display("[TB] Data asserted: 8'h55 (0101 0101). Waiting for Ready...");

        while (tx_if.ready == 1'b0) begin
            @(posedge clk);
        end
 
        @(posedge clk); 
        tx_if.valid = 1'b0;
        $display("[TB] Data 8'h55 captured by DUT. Serializing data...");

        repeat(150) @(posedge clk);

        @(posedge clk);
        tx_if.valid = 1'b1;
        tx_if.data = 8'hAB; 
        
        while (tx_if.ready == 1'b0) begin
            @(posedge clk);
        end
        
        @(posedge clk);
        tx_if.valid = 1'b0;
        $display("[TB] Data 8'hAB (1010 1011) captured. Waiting for end of transmission...");

        repeat (150) @(posedge clk);

        $display("========================================");
        $display("[TB] TX simulation completed.");
        $display("========================================");
        $finish;
    end

    // =========================================================
    // CHECKER
    // =========================================================
    initial begin
        logic [7:0] captured_byte;
        int bit_time = CLK_FREQ / BAUD_RATE; // 10 cycles
        
        forever begin
            @(negedge tx_serial_out);
            repeat (bit_time / 2) @(posedge clk);
            
            if(tx_serial_out !== 1'b0) begin
                $error("[CHECKER FAIL] False START bit.");
            end else begin
                for(int i = 0; i < 8; i++) begin
                    repeat (bit_time) @(posedge clk); 
                    captured_byte[i] = tx_serial_out; 
                end
                
                repeat (bit_time) @(posedge clk);
                if(tx_serial_out !== 1'b1) begin
                    $error("[CHECKER FAIL] Missing STOP bit. Captured fail frame: 8'h%0h", captured_byte);
                end else begin
                    $display("[CHECKER PASS] Valid frame: 8'h%0h", captured_byte);
                end
            end
        end
    end

endmodule
