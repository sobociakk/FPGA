`timescale 1ns / 1ps
`default_nettype none

module tb_transaction_test;

    import rtc_env_pkg::*;

    initial begin
        rtc_transaction tx;
        tx = new();

        $display("-------------------------------------------");
        $display("--- STARTING RANDOMIZATION TEST         ---");
        $display("-------------------------------------------");

        repeat(5) begin
            if (!tx.randomize()) $fatal(1, "[FATAL ERROR] Randomization failed!");
            tx.print();
        end

        $display("-------------------------------------------");
        $display("--- TEST FINISHED                       ---");
        $display("-------------------------------------------");
    end

endmodule