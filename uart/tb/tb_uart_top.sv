`timescale 1ns / 1ps

module tb_uart_top;
    localparam int CLK_FREQ  = 100_000_000;
    localparam int BAUD_RATE = 1_250_000;
    localparam int TEST_BYTES = 4;

    logic clk;
    logic rst_n;
    
    // HARDWARE LOOPBACK WIRE
    logic serial_loopback_wire; 

    int timeout_cnt;
    int error_cnt;

    // Test Payload Array (DEADBEEF)
    logic [7:0] payload [0:3] = '{8'hDE, 8'hAD, 8'hBE, 8'hEF};

    uart_tx_if tx_if();
    uart_rx_if rx_if();

    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .FIFO_DEPTH(16)
    ) DUT (
        .clk_i(clk),
        .rst_ni(rst_n),
        .tx_o(serial_loopback_wire), 
        .rx_i(serial_loopback_wire), 
        .bus_tx_i(tx_if),
        .bus_rx_o(rx_if)
    );

    // =========================================================
    // TASK: Push array of bytes to TX interface
    // =========================================================
    task automatic push_stream_to_tx(ref logic [7:0] data_stream []);
        $display("[TB] Task: Pushing %0d bytes to TX...", data_stream.size());
        foreach (data_stream[i]) begin
            @(posedge clk);
            tx_if.valid = 1'b1;
            tx_if.data  = data_stream[i];
            
            while (tx_if.ready == 1'b0) begin
                @(posedge clk);
            end
            
            @(posedge clk);
            tx_if.valid = 1'b0;
            $display("[TB] TX accepted byte %0d: 8'h%0h", i, data_stream[i]); 
        end
        $display("[TB] Task: Finished pushing data to TX.");
    endtask

    // =========================================================
    // TASK: Wait for RX, pop bytes, and check against expected array
    // =========================================================
    task automatic check_stream_from_rx(ref logic [7:0] expected_stream []);
        int local_timeout;
        $display("[TB] Task: Waiting to receive and verify %0d bytes from RX...", expected_stream.size());
        
        foreach (expected_stream[i]) begin
            local_timeout = 0;
            
            // Increased timeout to 50000 just to be safe for longer packets
            while (rx_if.valid == 1'b0 && local_timeout < 50000) begin
                @(posedge clk);
                local_timeout++;
            end

            if (local_timeout >= 50000) begin
                $error("[FAIL] Timeout! Missing byte index %0d.", i);
                $finish;
            end

            if (rx_if.data === expected_stream[i]) begin
                $display("[PASS] Byte %0d OK: 8'h%0h", i, rx_if.data);
            end else begin
                $error("[FAIL] Byte %0d ERROR: expected 8'h%0h, got 8'h%0h", i, expected_stream[i], rx_if.data);
                error_cnt++;
            end

            // Hardware handshake and 1 cycle breathing room
            @(posedge clk);
            rx_if.ready = 1'b1; 
            @(posedge clk);
            rx_if.ready = 1'b0;
            @(posedge clk); 
        end
        $display("[TB] Task: Finished checking RX stream.");
    endtask

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // MAIN TEST THREAD (Host Processor)
    // =========================================================
    /*
    logic [7:0] packet_1 [] = '{8'hDE, 8'hAD, 8'hBE, 8'hEF};
    logic [7:0] packet_2 [] = '{8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77, 8'h88};

    initial begin
        rst_n = 1'b0;
        tx_if.valid = 1'b0;
        tx_if.data = 8'h00;
        rx_if.ready = 1'b0;
        error_cnt = 0;
        
        #20 rst_n = 1'b1; #20;

        $display("==================================================");
        $display("[TB] STARTING TRANSACTION-LEVEL LOOPBACK TEST");
        $display("==================================================");

        // --- TEST 1: Short Packet (4 bytes) ---
        push_stream_to_tx(packet_1);
        check_stream_from_rx(packet_1);

        // Give hardware a moment of idle time between packets
        repeat(500) @(posedge clk);

        // --- TEST 2: Long Packet (8 bytes) ---
        push_stream_to_tx(packet_2);
        check_stream_from_rx(packet_2);

        // --- FINAL RESULT ---
        $display("==================================================");
        if (error_cnt == 0) begin
            $display("[TB] RESULT: SUCCESS");
        end else begin
            $display("[TB] RESULT: FAILED with %0d errors.", error_cnt);
        end
        $display("==================================================");
        $finish;
    end
    */

    class uart_packet;
    rand logic [7:0] data []; 

    constraint c_packet_size {
        data.size() inside {[16:64]};
    }
    endclass

    initial begin
        uart_packet pkt;
        
        rst_n = 1'b0;
        tx_if.valid = 1'b0;
        rx_if.ready = 1'b0;
        error_cnt = 0;
        
        #50 rst_n = 1'b1;
        repeat(10) @(posedge clk);

        $display("==================================================");
        $display("[TB] STARTING RANDOMIZED PARALLEL TEST");
        $display("==================================================");

        repeat(5) begin 
            pkt = new();
            if (!pkt.randomize()) $error("Randomization failed.");

            $display("[TB] Testing new packet with size: %0d", pkt.data.size());

            fork
                push_stream_to_tx(pkt.data);
                check_stream_from_rx(pkt.data);
            join
            
            $display("[TB] Transaction finished. Idle time...");
            repeat(100) @(posedge clk);
        end

        $display("==================================================");
        if (error_cnt == 0) begin
            $display("[TB] RESULT: SUCCESS");
        end else begin
            $display("[TB] RESULT: FAILED with %0d errors.", error_cnt);
        end
        $display("==================================================");
        $finish;
    end

endmodule