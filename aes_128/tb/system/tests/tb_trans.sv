`timescale 1ns / 1ps

module tb_trans;
    import calc_env_pkg::*;

    initial begin
        calc_transaction tx;
        tx = new();

        $display("-------------------------------------------");
        repeat(5) begin
            if (!tx.randomize()) $fatal(1, "[FATAL ERROR] Randomization failed");
            tx.print();
        end
        $display("-------------------------------------------");
    end
endmodule
