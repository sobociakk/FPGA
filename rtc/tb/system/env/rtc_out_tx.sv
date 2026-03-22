class rtc_out_tx;
    logic [3:0] anode;    
    logic [3:0] digit_val;  
    
    function void print();
        $display("[OUT_TX] Anode: %b, Value: %0d", anode, digit_val);
    endfunction
endclass