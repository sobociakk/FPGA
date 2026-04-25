`timescale 1ns / 1ps
`default_nettype none

// ============================================================
//  tb_top — Top-level testbench module (Spear Ch. 2.1)
//
//  Contains:
//    - Clock generator (pure module territory)
//    - Interface instantiation
//    - DUT instantiation
//    - program automatic calc_tb (Spear Ch. 2.2)
//        The program block provides a race-free zone for TB code.
//        It executes in the Re-NBA region and terminates simulation
//        cleanly via $finish when the test completes.
//
//  Parameters reduced for simulation speed:
//    CYCLES_1KHZ = 1_000  → display refresh at 100 kHz (instead of 1 kHz)
// ============================================================

module tb_top;
    import calc_env_pkg::*;

    // --- System clock: 100 MHz (10 ns period) ---
    logic clk;
    initial clk = 1'b0;
    always  #5 clk = ~clk;

    // --- Virtual interface ---
    calc_if if_calc(.clk(clk));

    // --- DUT ---
    top #(
        .CLK_FREQ(100_000_000),
        .CYCLES_1KHZ(1_000)
    ) DUT (
        .clk(clk),
        .btnC(if_calc.rst),
        .PS2Clk(if_calc.ps2_clk),
        .PS2Data(if_calc.ps2_data),
        .seg(if_calc.led7_seg_o),
        .an(if_calc.led7_an_o)
    );

    calc_tb tb_inst(.vif(if_calc));
endmodule


// ============================================================
//  calc_tb — program block 
//
//  The program block runs in the Re-NBA scheduling region,
//  AFTER all module always blocks settle. This eliminates the
//  classic "drive at the same edge as sample" race condition.
//
//  Reset sequence:
//    - PS/2 idle state: both clk and data high
//    - Assert reset (btnC high) for 10 clock cycles
//    - De-assert reset; wait 10 cycles for DUT to settle
// ============================================================
program automatic calc_tb (calc_if.tb vif);
    import calc_env_pkg::*;

    initial begin
        calc_test t;

        // --- PS/2 idle state + reset assert ---
        vif.tb_cb.ps2_clk <= 1'b1;
        vif.tb_cb.ps2_data <= 1'b1;
        vif.tb_cb.rst <= 1'b1;

        repeat(10) @(vif.tb_cb);

        // --- De-assert reset ---
        vif.tb_cb.rst <= 1'b0;
        repeat(10) @(vif.tb_cb);

        // --- Run test ---
        t = new(vif);
        t.run();

        $finish;
    end
endprogram

/*
Największym problemem w symulacji sprzętu są wyścigi (race conditions)
Blok program rozwiązuje to przez "fazy":
Active region: Tu pracuje Twój projekt (logika przerzutników, bramek).
Reactive region: Tu pracuje blok program (Twój test).
Dzięki temu masz gwarancję, że testbench odczytuje sygnały z projektu dopiero wtedy, 
gdy wszystkie obliczenia wewnątrz logiki sprzętowej na dany cykl zegara zostały już zakończone.
*/

/*
Automatic:
Domyślnie w starym Verilogu wszystko było statyczne (static). Oznaczało to, że jeśli miałeś zmienną wewnątrz funkcji, 
to istniała tylko jedna jej kopia w pamięci na całą symulację.
Dlaczego to problem?
Jeśli uruchomisz dwa procesy równolegle (np. dwa Drivery wysyłające dane w tym samym czasie), a oba używają 
tej samej zmiennej pomocniczej tmp, to będą sobie nawzajem nadpisywać jej wartość.
Słowo automatic zmienia zasady:
Zmienne są tworzone na stosie (stack) w momencie wywołania zadania/funkcji.
Każde wywołanie ma swoją własną, prywatną kopię zmiennych.
Jest to niezbędne do Programowania Obiektowego (OOP) i rekurencji.
*/

`default_nettype wire
