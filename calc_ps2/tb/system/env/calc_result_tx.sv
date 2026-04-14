class calc_result_tx;

    logic [15:0] display_val;   

    function void do_print();
        $display("[RESULT_TX] display_val = 16'h%04X", display_val);
    endfunction
endclass
