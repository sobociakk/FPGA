class calc_scb;
    mailbox #(calc_transaction) gen2scb;
    mailbox #(calc_result_tx) mon2scb;

    int passed;
    int failed;
    int total_checked;   

    function new(
        mailbox #(calc_transaction) gen2scb,
        mailbox #(calc_result_tx) mon2scb
    );
        this.gen2scb = gen2scb;
        this.mon2scb = mon2scb;
        passed = 0;
        failed = 0;
        total_checked = 0;
    endfunction

    task run();
        calc_transaction expected;
        calc_result_tx observed;
        $display("[SCB] Starting...");
        forever begin
            gen2scb.get(expected);  
            mon2scb.get(observed);  
            check_pair(expected, observed);
            total_checked++;
        end
    endtask


    task wait_for_n(int n);
        wait(total_checked >= n);
    endtask

    function void check_pair(calc_transaction tx, calc_result_tx obs);
        logic [15:0] expected_val;
        expected_val = reference_model(tx);

        if (obs.display_val === expected_val) begin
            passed++;
            $display("[SCB] [PASS] %0d %0s %0d → expected=16'h%04X  got=16'h%04X",
                tx.arg1, tx.op ? "-" : "+", tx.arg2, expected_val, obs.display_val);
        end else begin
            failed++;
            $display("[SCB] [FAIL] %0d %0s %0d → expected=16'h%04X  got=16'h%04X  ← MISMATCH",
                tx.arg1, tx.op ? "-" : "+", tx.arg2, expected_val, obs.display_val);
        end
    endfunction

    local function logic [15:0] reference_model(calc_transaction tx);
        int signed val_res;
        int unsigned abs_val;
        logic [15:0] bcd;

        if (tx.op == 1'b0) val_res = int'(tx.arg1) + int'(tx.arg2);
        else val_res = int'(tx.arg1) - int'(tx.arg2);

        if(val_res > 9999 || val_res < -999)
            return 16'hFECC;

        if(val_res >= 0) begin
            bcd = int_to_bcd(val_res);
            return bcd;
        end

        abs_val = -val_res;   // 1..999
        bcd = int_to_bcd(abs_val);
        if(abs_val > 99) return {4'hA, bcd[11:0]};          // -100..-999 → Axxx
        else if(abs_val > 9) return {4'hF, 4'hA, bcd[7:0]};    // -10..-99   → FAxx
        else return {4'hF, 4'hF, 4'hA, bcd[3:0]}; // -1..-9  → FFAx

    endfunction

    local function logic [15:0] int_to_bcd(int unsigned val);
        logic [15:0] bcd;
        bcd = '0;
        bcd[15:12] = val / 1000;
        bcd[11:8] = (val % 1000) / 100;
        bcd[7:4] = (val % 100) / 10;
        bcd[3:0] = val % 10;
        return bcd;
    endfunction

    function void print_summary();
        $display("=========================================");
        $display("=== SCOREBOARD SUMMARY                ===");
        $display("  PASSED : %0d", passed);
        $display("  FAILED : %0d", failed);
        if (failed == 0)
            $display("  RESULT : [SUCCESS] ✓");
        else
            $display("  RESULT : [FAILURE] — %0d mismatch(es)", failed);
        $display("=========================================");
    endfunction

endclass
