class calc_test;
    calc_env env;
    virtual calc_if vif;

    function new(virtual calc_if vif);
        this.vif = vif;
        this.env = new(vif);
    endfunction

    task run();
        $display("===========================================");
        $display("=== CALC PS2 TESTBENCH STARTING         ===");
        $display("===========================================");

        // Uruchom monitor i scoreboard w tle (fork...join_none w env.run())
        env.run();

        // ESC na starcie — pewny stan początkowy
        env.drv.press_esc();
        repeat(5000) @(posedge vif.clk);

        run_directed();
        run_random(20);

        env.scb.print_summary();
        $finish;
    endtask

    // ------------------------------------------------------------------
    // Directed tests — znane scenariusze z przewidywalnym wynikiem
    // ------------------------------------------------------------------
    task run_directed();
        calc_transaction tx;

        $display("--- DIRECTED TESTS ---");

        // Test 1: 0 + 0 = 0
        tx = new(); tx.arg1 = 0; tx.arg2 = 0; tx.op = 0;
        tx.print(); env.drv.drive(tx);
        wait_for_display(); env.scb.check(tx);
        env.drv.press_esc(); repeat(2000) @(posedge vif.clk);

        // Test 2: 12 + 34 = 46
        tx = new(); tx.arg1 = 12; tx.arg2 = 34; tx.op = 0;
        tx.print(); env.drv.drive(tx);
        wait_for_display(); env.scb.check(tx);
        env.drv.press_esc(); repeat(2000) @(posedge vif.clk);

        // Test 3: 9999 + 1 = 9999 (saturacja górna)
        tx = new(); tx.arg1 = 9999; tx.arg2 = 1; tx.op = 0;
        tx.print(); env.drv.drive(tx);
        wait_for_display(); env.scb.check(tx);
        env.drv.press_esc(); repeat(2000) @(posedge vif.clk);

        // Test 4: 50 - 23 = 27
        tx = new(); tx.arg1 = 50; tx.arg2 = 23; tx.op = 1;
        tx.print(); env.drv.drive(tx);
        wait_for_display(); env.scb.check(tx);
        env.drv.press_esc(); repeat(2000) @(posedge vif.clk);

        // Test 5: 10 - 20 = 0 (saturacja dolna)
        tx = new(); tx.arg1 = 10; tx.arg2 = 20; tx.op = 1;
        tx.print(); env.drv.drive(tx);
        wait_for_display(); env.scb.check(tx);
        env.drv.press_esc(); repeat(2000) @(posedge vif.clk);

        // Test 6: 9999 - 9999 = 0
        tx = new(); tx.arg1 = 9999; tx.arg2 = 9999; tx.op = 1;
        tx.print(); env.drv.drive(tx);
        wait_for_display(); env.scb.check(tx);
        env.drv.press_esc(); repeat(2000) @(posedge vif.clk);
    endtask

    // ------------------------------------------------------------------
    // Random tests — losowe transakcje, scoreboard liczy oczekiwany wynik
    // ------------------------------------------------------------------
    task run_random(int n);
        calc_transaction tx;
        $display("--- RANDOM TESTS (n=%0d) ---", n);
        repeat(n) begin
            tx = new();
            if (!tx.randomize()) $fatal(1, "[FATAL] Randomization failed!");
            tx.print();
            env.drv.drive(tx);
            wait_for_display();
            env.scb.check(tx);
            env.drv.press_esc();
            repeat(2000) @(posedge vif.clk);
        end
    endtask

    // ------------------------------------------------------------------
    // wait_for_display — czeka aż wyświetlacz odświeży wszystkie 4 cyfry.
    // CYCLES_1KHZ = 1000 w symulacji → 4 pełne cykle = 4*1000 = 4000 cykli.
    // Czekamy 10x zapas = 10000 cykli.
    // ------------------------------------------------------------------
    task wait_for_display();
        repeat(10000) @(posedge vif.clk);
    endtask

endclass
