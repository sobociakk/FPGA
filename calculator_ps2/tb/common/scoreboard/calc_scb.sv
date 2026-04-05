class calc_scb;
    // Ostatni zaobserwowany stan wyświetlacza (4 cyfry BCD).
    // Indeks odpowiada pozycji: 0=jednostki, 1=dziesiątki, 2=setki, 3=tysiące.
    logic [3:0] last_digit[4];

    mailbox #(calc_out_tx) mon2scb_mbx;

    int passed;
    int failed;

    function new(mailbox #(calc_out_tx) mbx);
        this.mon2scb_mbx = mbx;
        passed = 0;
        failed = 0;
    endfunction

    // ------------------------------------------------------------------
    // run — pętla odbierająca obserwacje z monitora.
    //   Każda obserwacja (anode + digit_val) wpisywana jest do właściwego
    //   slotu na podstawie wartości anody (active-low, jeden bit=0).
    //   Uruchamiaj w fork...join_none razem z monitor.run().
    // ------------------------------------------------------------------
    task run();
        calc_out_tx item;
        $display("[SCB] Starting...");

        forever begin
            mon2scb_mbx.get(item);
            case (item.anode)
                4'b1110: last_digit[0] = item.digit_val; // jednostki
                4'b1101: last_digit[1] = item.digit_val; // dziesiątki
                4'b1011: last_digit[2] = item.digit_val; // setki
                4'b0111: last_digit[3] = item.digit_val; // tysiące
            endcase
        end
    endtask

    // ------------------------------------------------------------------
    // check — model referencyjny + porównanie.
    //   Wywołwany przez test PO wysłaniu transakcji i odczekaniu
    //   wystarczającej liczby cykli na ustabilizowanie wyświetlacza.
    //
    //   Model referencyjny odwzorowuje logikę z alu.sv:
    //     - dodawanie lub odejmowanie
    //     - saturacja: wynik < 0  → 0
    //                  wynik > 9999 → 9999
    // ------------------------------------------------------------------
    function void check(calc_transaction tx);
        int unsigned expected;
        int unsigned observed;

        // --- Model referencyjny ---
        if (tx.op == 1'b0) begin // dodawanie
            expected = tx.arg1 + tx.arg2;
            if (expected > 9999) expected = 9999;
        end else begin           // odejmowanie
            if (tx.arg1 >= tx.arg2) expected = tx.arg1 - tx.arg2;
            else                    expected = 0;
        end

        // --- Odczyt zaobserwowanego wyniku ---
        observed = last_digit[3] * 1000
                 + last_digit[2] * 100
                 + last_digit[1] * 10
                 + last_digit[0];

        // --- Porównanie ---
        if (observed == expected) begin
            passed++;
            $display("[SCB] [PASS] %0d %s %0d = %0d (got %0d)",
                tx.arg1, tx.op ? "-" : "+", tx.arg2, expected, observed);
        end else begin
            failed++;
            $display("[SCB] [FAIL] %0d %s %0d = %0d (got %0d) ← MISMATCH",
                tx.arg1, tx.op ? "-" : "+", tx.arg2, expected, observed);
        end
    endfunction

    // ------------------------------------------------------------------
    // print_summary — wywoływany na końcu testu.
    // ------------------------------------------------------------------
    function void print_summary();
        $display("=========================================");
        $display("=== SCOREBOARD SUMMARY                ===");
        $display("  PASSED : %0d", passed);
        $display("  FAILED : %0d", failed);
        if (failed == 0)
            $display("  RESULT : [SUCCESS]");
        else
            $display("  RESULT : [FAILURE]");
        $display("=========================================");
    endfunction

endclass
