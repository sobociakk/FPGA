// ============================================================
//  calc_test — Top-level test class (Spear Ch. 4.3)
//
//  Orchestrates the verification scenario:
//    1. ESC to reset DUT to known state
//    2. run_directed() — 6 deterministic corner-case transactions
//    3. run_random(N)  — N randomized transactions via generator
//
//  Directed tests call env.directed_drive() which feeds the
//  scoreboard pipeline automatically (no manual check() needed).
//
//  Random tests use the generator: gen.run(N) produces N
//  transactions → gen2drv (driver) and gen2scb (scoreboard).
//  Driver.run() consumes them and triggers evt_capture each time.
//  Monitor captures one frame per trigger → mon2scb → scoreboard.
//
//  After all transactions, wait for the last SCB check to
//  complete, then print summary and coverage report.
// ============================================================
class calc_test;
    calc_env env;
    virtual calc_if.tb vif;

    // Cycles to wait after ESC before next transaction
    localparam int ESC_WAIT = 3000;
    // Drain: wait for last random result to propagate through driver+monitor+SCB.
    // Each random tx ≈ 5 digits * 3 bytes * 22*CLK_HALF + operator + enter:
    //   worst case: ~15 bytes * 22*2000 = 660_000 cycles; 20 tx = 13_200_000.
    // Use 3_000_000 (covers typical case; increase if >4-digit numbers needed).
    localparam int DRAIN_WAIT = 3_000_000;

    function new(virtual calc_if.tb vif);
        this.vif = vif;
        this.env = new(vif);
    endfunction

    task run();
        $display("==========================================");
        $display("=== CALC PS2 TESTBENCH STARTING       ===");
        $display("==========================================");

        // Start driver, monitor, scoreboard in background
        env.run();

        // Initial ESC — guarantee clean FSM state
        env.press_esc();
        repeat(ESC_WAIT) @(vif.tb_cb);

        run_directed();
        run_random(20);

        // Wait until scoreboard has paired all 29 transactions (9 directed + 20 random)
        env.scb.wait_for_n(29);

        env.scb.print_summary();
        env.cov.report();
    endtask

    // ------------------------------------------------------------------
    // run_directed — deterministic corner cases (Spear Ch. 4 — directed)
    // ------------------------------------------------------------------
    task run_directed();
        calc_transaction tx;
        $display("--- DIRECTED TESTS ---");

        // Test 1: 0 + 0 = 0
        tx = new(); tx.arg1 = 0; tx.arg2 = 0; tx.op = 0;
        drive_and_sample(tx);

        // Test 2: 12 + 34 = 46
        tx = new(); tx.arg1 = 12; tx.arg2 = 34; tx.op = 0;
        drive_and_sample(tx);

        // Test 3: 9999 + 1 → Err (overflow)
        tx = new(); tx.arg1 = 9999; tx.arg2 = 1; tx.op = 0;
        drive_and_sample(tx);

        // Test 4: 50 - 23 = 27
        tx = new(); tx.arg1 = 50; tx.arg2 = 23; tx.op = 1;
        drive_and_sample(tx);

        // Test 5: 10 - 20 = -10  (negative result, displayed as FA10)
        tx = new(); tx.arg1 = 10; tx.arg2 = 20; tx.op = 1;
        drive_and_sample(tx);

        // Test 6: 0 - 1000 → Err  (deep negative: 0-1000 = -1000 < -999)
        // Pokrywa cp_deep_neg.err_negative oraz cp_cross subtraction×b_zero
        tx = new(); tx.arg1 = 0; tx.arg2 = 1000; tx.op = 1;
        drive_and_sample(tx);

        // Test 7: 0 + 500 = 500  (arg1 == 0 → pokrywa bin b_zero w cp_arg1)
        tx = new(); tx.arg1 = 0; tx.arg2 = 500; tx.op = 0;
        drive_and_sample(tx);

        // Test 8: 750 - 0 = 750  (arg2 == 0 → pokrywa bin b_zero w cp_arg2)
        tx = new(); tx.arg1 = 750; tx.arg2 = 0; tx.op = 1;
        drive_and_sample(tx);

        // Test 9: 9999 - 9999 = 0  (cp_max_val + cp_cross subtraction×b_big)
        tx = new(); tx.arg1 = 9999; tx.arg2 = 9999; tx.op = 1;
        drive_and_sample(tx);

        $display("--- DIRECTED TESTS DONE ---");
    endtask

    // drive_and_sample — single directed transaction helper
    local task drive_and_sample(calc_transaction tx);
        tx.do_print("DIRECTED");
        env.cov.sample(tx);           // sample coverage (Spear Ch. 7)
        env.directed_drive(tx);       // drives DUT + feeds SCB expected
        esc_and_wait();               // reset calculator for next test
    endtask

    // ------------------------------------------------------------------
    // run_random — generator-based random flow (Spear Ch. 4.4)
    // ------------------------------------------------------------------
    task run_random(int n);
        $display("--- RANDOM TESTS (n=%0d) ---", n);
        env.gen.num_transactions = n;
        // Driver and SCB already run in background (env.run()).
        // Generator runs to completion pushing n items to gen2drv + gen2scb.
        env.gen.run();
        $display("--- RANDOM TESTS DONE ---");
    endtask

    // ESC + idle wait between transactions
    local task esc_and_wait();
        env.press_esc();
        repeat(ESC_WAIT) @(vif.tb_cb);
    endtask

endclass
