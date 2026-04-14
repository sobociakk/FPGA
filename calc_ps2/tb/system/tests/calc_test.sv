class calc_test;
    calc_env env;
    virtual calc_if.tb vif;
    localparam int ESC_WAIT   = 3000;
    localparam int DRAIN_WAIT = 3_000_000;

    function new(virtual calc_if.tb vif);
        this.vif = vif;
        this.env = new(vif);
    endfunction

    task run();
        $display("==========================================");
        $display("=== CALC PS2 TESTBENCH STARTING       ===");
        $display("==========================================");

        env.run();
        env.press_esc();
        repeat(ESC_WAIT) @(vif.tb_cb);

        run_directed();
        run_random(20);

        env.scb.wait_for_n(29);
        env.scb.print_summary();
        env.cov.report();
    endtask

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

    local task drive_and_sample(calc_transaction tx);
        tx.do_print("DIRECTED");
        env.cov.sample(tx);           
        env.directed_drive(tx);       
        esc_and_wait();             
    endtask

    task run_random(int n);
        $display("--- RANDOM TESTS (n=%0d) ---", n);
        env.gen.num_transactions = n;
        env.gen.run();
        $display("--- RANDOM TESTS DONE ---");
    endtask

    local task esc_and_wait();
        env.press_esc();
        repeat(ESC_WAIT) @(vif.tb_cb);
    endtask
endclass
