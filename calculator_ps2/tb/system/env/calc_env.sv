class calc_env;
    calc_driver drv;
    calc_monitor mon;
    calc_scb scb;
    mailbox #(calc_out_tx) mon2scb_mbx;
    virtual calc_if vif;

    function new(virtual calc_if vif);
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
