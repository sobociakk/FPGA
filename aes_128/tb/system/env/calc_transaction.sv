class calc_transaction;

    rand int unsigned arg1;
    rand int unsigned arg2;
    rand bit op;   // 0 = addition, 1 = subtraction

    constraint c_args {
        arg1 inside {[0:9999]};
        arg2 inside {[0:9999]};
    }

    // Bias toward arg2 > arg1 when subtracting to exercise negative-result path
    // Test can disable via tx.c_negative_bias.constraint_mode(0)
    constraint c_negative_bias {
        soft (op == 1'b1) -> (arg2 > arg1);
    }

    function calc_transaction copy();
        copy = new();
        copy.arg1 = this.arg1;
        copy.arg2 = this.arg2;
        copy.op = this.op;
    endfunction

    function bit do_compare(calc_transaction rhs);
        return (this.arg1 == rhs.arg1) && (this.arg2 == rhs.arg2) && (this.op == rhs.op);
    endfunction

    function void do_print(string tag = "");
        $display("[TX%0s] arg1=%0d  op=%0s  arg2=%0d", (tag != "") ? {":", tag} : "", arg1, op ? "-" : "+", arg2);
    endfunction
endclass
