class calc_coverage;

    covergroup cg_calc with function sample(calc_transaction tx);

        // Operation type
        cp_op: coverpoint tx.op {
            bins addition = {1'b0};
            bins subtraction = {1'b1};
        }

        // arg1 value range
        cp_arg1: coverpoint tx.arg1 {
            bins b_zero = {[0:0]};
            bins b_tiny = {[1:99]};
            bins b_mid = {[100:999]};
            bins b_big = {[1000:9999]};
        }

        // arg2 value range
        cp_arg2: coverpoint tx.arg2 {
            bins b_zero = {[0:0]};
            bins b_tiny = {[1:99]};
            bins b_mid = {[100:999]};
            bins b_big = {[1000:9999]};
        }

        // Cross: operation x arg1 range
        cp_cross_op_arg1: cross cp_op, cp_arg1;

        // Addition overflow: result > 9999 → Err
        cp_overflow: coverpoint(tx.op == 1'b0 && (int'(tx.arg1) + int'(tx.arg2) > 9999)) {
            bins overflow = {1'b1};
            bins no_overflow = {1'b0};
        }

        // Subtraction: negative result
        cp_underflow: coverpoint(tx.op == 1'b1 && tx.arg2 > tx.arg1) {
            bins negative = {1'b1};
            bins non_negative = {1'b0};
        }

        // Subtraction: deep negative → Err (arg2 - arg1 > 999)
        cp_deep_neg: coverpoint(tx.op == 1'b1 && tx.arg2 > tx.arg1 && (int'(tx.arg2) - int'(tx.arg1)) > 999) {
            bins err_negative = {1'b1};
            bins ok = {1'b0};
        }

        // Boundary: arg1 or arg2 == 9999
        cp_max_val: coverpoint(tx.arg1 == 9999 || tx.arg2 == 9999) {
            bins has_max = {1'b1};
            bins no_max = {1'b0};
        }

    endgroup

    function new();
        cg_calc = new();
    endfunction

    // sample() — call after each transaction 
    function void sample(calc_transaction tx);
        cg_calc.sample(tx);
    endfunction

    // report() — print coverage at end of test
    function void report();
        real cov;
        cov = cg_calc.get_coverage();
        $display("=========================================");
        $display("=== COVERAGE REPORT                   ===");
        $display("  cg_calc total coverage : %0.1f%%", cov);
        $display("  cp_op                  : %0.1f%%", cg_calc.cp_op.get_coverage());
        $display("  cp_arg1                : %0.1f%%", cg_calc.cp_arg1.get_coverage());
        $display("  cp_arg2                : %0.1f%%", cg_calc.cp_arg2.get_coverage());
        $display("  cp_overflow            : %0.1f%%", cg_calc.cp_overflow.get_coverage());
        $display("  cp_underflow           : %0.1f%%", cg_calc.cp_underflow.get_coverage());
        $display("=========================================");
    endfunction

endclass
