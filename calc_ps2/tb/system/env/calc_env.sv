class calc_env;
    calc_generator gen;
    calc_driver drv;
    calc_monitor mon;
    calc_scb scb;
    calc_coverage cov;

    mailbox #(calc_transaction) gen2drv;   
    mailbox #(calc_transaction) gen2scb;   
    mailbox #(calc_result_tx) mon2scb;  

    event evt_capture;  

    virtual calc_if.tb vif;

    function new(virtual calc_if.tb vif);
        this.vif = vif;
        gen2drv = new();
        gen2scb = new();
        mon2scb = new();
        gen = new(gen2drv, gen2scb);
        drv = new(vif, gen2drv, evt_capture);
        mon = new(vif, mon2scb, evt_capture);
        scb = new(gen2scb, mon2scb);
        cov = new();
    endfunction

    task run();
        fork
            drv.run(); 
            mon.run();   
            scb.run();   
        join_none
    endtask

    task directed_drive(calc_transaction tx);
        gen2scb.put(tx.copy());
        drv.drive(tx);
    endtask

    task press_esc();
        drv.press_esc();
    endtask
endclass
