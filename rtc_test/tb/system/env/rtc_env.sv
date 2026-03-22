class rtc_env;
    rtc_driver drv;
    rtc_monitor mon;
    rtc_scoreboard scb;
    mailbox #(rtc_out_tx) mon2scb_mbx;
    virtual rtc_if vif;

    function new(virtual rtc_if vif);
        this.vif = vif;
        mon2scb_mbx = new();
        drv = new(vif);
        mon = new(vif, mon2scb_mbx);
        scb = new(mon2scb_mbx);
    endfunction
    
    task run();
        fork
            mon.run();
            scb.run();
        join_none
    endtask
endclass