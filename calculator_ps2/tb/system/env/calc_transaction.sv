class calc_transaction;
    rand int unsigned arg1; 
    rand int unsigned arg2;
    rand bit op;   // 0 = addition, 1 = subtraction

    constraint c_args {
        arg1 inside {[0:9999]};
        arg2 inside {[0:9999]};
    }

    function void print();
        $display("[TRANSACTION] Arg1: %0d | Arg2: %0d | Op: %0d", arg1, arg2, op);
    endfunction
endclass
