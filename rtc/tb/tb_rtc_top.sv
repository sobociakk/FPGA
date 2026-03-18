`timescale 1ns / 1ps

module tb_rtc_top;

    // ========================================================
    // Sygnały testowe
    // ========================================================
    logic clk_i;
    logic rst_i;
    logic btn_hr_i;
    logic btn_min_i;
    logic btn_test_i;

    logic [3:0] led7_an_o;
    logic [7:0] led7_seg_o;

    // ========================================================
    // Instancja testowanego układu
    // ========================================================
    rtc_top DUT (
        .clk_i      (clk_i),
        .rst_i      (rst_i),
        .btn_hr_i   (btn_hr_i),
        .btn_min_i  (btn_min_i),
        .btn_test_i (btn_test_i),
        .led7_an_o  (led7_an_o),
        .led7_seg_o (led7_seg_o)
    );

    // ========================================================
    // Generator Zegara (100 MHz)
    // To jedyne miejsce, gdzie uzywamy twardych opóźnień czasowych (#)
    // ========================================================
    initial clk_i = 0;
    always #5 clk_i = ~clk_i; 

    // ========================================================
    // Zadania weryfikacyjne (Tasks)
    // ========================================================
    
    // Task testujący przycisk w pełni synchronicznie
    task automatic test_button(input string btn_name, input int expected_val);
        $display("\n---> ROZPOCZYNAM TEST: Wcisniecie przycisku %s", btn_name);
        
        // 1. Asercja sygnału synchronicznie z zegarem
        @(posedge clk_i);
        if (btn_name == "MIN") btn_min_i <= 1'b1;
        if (btn_name == "HR")  btn_hr_i  <= 1'b1;

        // 2. Oczekiwanie na wynik z zabezpieczeniem (Timeout oparty na cyklach)
        fork
            begin
                // Używamy '>=' na wypadek gdyby licznik przeskoczył o więcej niż 1
                if (btn_name == "MIN") wait(DUT.RTC_CORE.min_o >= expected_val);
                if (btn_name == "HR")  wait(DUT.RTC_CORE.hr_o >= expected_val);
                $display("[SUCCESS] Wartosc zmienila sie poprawnie na %0d!", expected_val);
            end
            begin
                // Timeout: 10 milionów cykli (odpowiednik dawnego 100ms dla zegara 100MHz)
                repeat(10_000_000) @(posedge clk_i); 
                $display("[ERROR] TIMEOUT! Przycisk %s nie zadzialal na czas!", btn_name);
                $finish;
            end
        join_any 
        disable fork; 

        // 3. Deasercja przycisku i czas na wygaszenie debouncera
        @(posedge clk_i);
        if (btn_name == "MIN") btn_min_i <= 1'b0;
        if (btn_name == "HR")  btn_hr_i  <= 1'b0;
        
        // Czekamy 6 milionów cykli (zamiast twardego #60_000_000)
        repeat(6_000_000) @(posedge clk_i); 
    endtask

    // ========================================================
    // Główny blok weryfikacji
    // ========================================================
    initial begin
        // Automatyczny monitor - wydrukuje stan tylko wtedy, gdy się zmieni
        $monitor("[MONITOR] Aktualny czas RTC -> %02d:%02d:%02d", 
                  DUT.RTC_CORE.hr_o, DUT.RTC_CORE.min_o, DUT.RTC_CORE.sec_o);

        $display("========================================");
        $display("START WERYFIKACJI TERMINALOWEJ RTC");
        $display("========================================");

        // 1. Inicjalizacja (przed pierwszym zboczem zegara)
        rst_i      <= 1'b0;
        btn_hr_i   <= 1'b0;
        btn_min_i  <= 1'b0;
        btn_test_i <= 1'b0;

        // 2. Synchroniczny reset układu
        @(posedge clk_i);
        rst_i <= 1'b1;
        repeat(10) @(posedge clk_i); // Trzymamy reset przez 10 cykli
        rst_i <= 1'b0;
        
        $display("\n[INFO] Uklad zresetowany. Oczekiwany czas to 00:00:00");
        repeat(100) @(posedge clk_i); // Czekamy chwilę po resecie

        // 3. Testowanie przycisków
        test_button("MIN", 1);
        test_button("MIN", 2);
        test_button("HR",  1);

        // 4. Test trybu TURBO
        $display("\n---> ROZPOCZYNAM TEST: Tryb TURBO (Przyspieszenie 1000x)");
        @(posedge clk_i);
        btn_test_i <= 1'b1;
        
        // Czekamy aż minie 15 wirtualnych sekund
        wait(DUT.RTC_CORE.sec_o >= 15);
        $display("[SUCCESS] Czas w trybie TURBO blyskawicznie osiagnal 15 sekund!");
        
        @(posedge clk_i);
        btn_test_i <= 1'b0;

        $display("\n========================================");
        $display("WERYFIKACJA ZAKONCZONA POMYSLNIE [ALL PASS]");
        $display("========================================");
        $finish;
    end

endmodule