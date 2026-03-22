class rtc_driver;
    virtual rtc_if vif;

    function new(virtual rtc_if vif);
        this.vif = vif;
    endfunction

    task drive(rtc_transaction tx);
        @(posedge vif.clk);
        $display("[DRIVER] Driving -> HR: %0b | MIN: %0b | TEST: %0b", tx.btn_hr, tx.btn_min, tx.btn_test);
        
        vif.btn_hr_i <= tx.btn_hr;
        vif.btn_min_i <= tx.btn_min;
        vif.btn_test_i <= tx.btn_test;
        
        repeat(tx.hold_cycles) @(posedge vif.clk);
        $display("[DRIVER] Holding buttons for %0d cycles", tx.hold_cycles);
        
        vif.btn_hr_i <= 1'b0;
        vif.btn_min_i <= 1'b0;
        vif.btn_test_i <= 1'b0;
        repeat(20) @(posedge vif.clk);
    endtask
endclass