`timescale 1ns / 1ps
`default_nettype none

// ============================================================
//  tb_top — Top-level testbench module
//
//  Instantiates DUT and calc_if, drives reset sequence,
//  then hands control to calc_test.
//
//  Parametry zmniejszone dla szybszej symulacji:
//    CYCLES_1KHZ = 1000  (zamiast 100_000) — wyświetlacz 100kHz
// ============================================================

module tb_top;
    import calc_env_pkg::*;

    // --- Zegar systemowy: 100 MHz (10 ns okres) ---
    logic clk;
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // --- Interfejs ---
    calc_if if_calc(.clk(clk));

    // --- DUT ---
    top #(
        .CLK_FREQ    (100_000_000),
        .CYCLES_1KHZ (1_000)        // przyspieszone dla symulacji
    ) DUT (
        .clk      (clk),
        .btnC     (if_calc.rst),
        .PS2Clk   (if_calc.ps2_clk),
        .PS2Data  (if_calc.ps2_data),
        .seg      (if_calc.led7_seg_o),
        .an       (if_calc.led7_an_o)
    );

    // --- Sekwencja startowa i test ---
    initial begin
        calc_test t;

        // Inicjalizacja sygnałów (PS/2 idle = oba wysokie)
        if_calc.rst      = 1'b1;
        if_calc.ps2_clk  = 1'b1;
        if_calc.ps2_data = 1'b1;

        // Reset asynchroniczny: 10 cykli
        repeat(10) @(negedge clk);
        if_calc.rst = 1'b0;
        repeat(10) @(posedge clk);

        // Uruchom test
        t = new(if_calc);
        t.run();
    end

endmodule

`default_nettype wire
