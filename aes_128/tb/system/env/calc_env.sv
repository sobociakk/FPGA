//  Creates all components and wires them through mailboxes
//  and the shared evt_capture event. Mirrors the layered
//  testbench architecture from Spear Fig. 4.2:
//
//    generator --gen2drv--> driver  --[evt_capture]--> monitor
//              --gen2scb-->                                |
//                                               mon2scb   |
//              scoreboard <----gen2scb---- (expected) ----+
//              scoreboard <----mon2scb---- (observed) ----+
//
//  Public handle feed_expected() allows directed tests to inject
//  into the gen2scb pipeline without going through the generator

class calc_env;
    calc_generator gen;
    calc_driver drv;
    calc_monitor mon;
    calc_scb scb;
    calc_coverage cov;

    mailbox #(calc_transaction) gen2drv;   // generator → driver
    mailbox #(calc_transaction) gen2scb;   // generator/test → scoreboard (expected)
    mailbox #(calc_result_tx)   mon2scb;   // monitor → scoreboard (observed)

    event evt_capture;   // driver signals monitor: "capture next result frame"

    virtual calc_if.tb vif;

    function new(virtual calc_if.tb vif);
        this.vif = vif;

        gen2drv = new();
        gen2scb = new();
        mon2scb = new();

        // Instantiate components, passing their communication handles
        gen = new(gen2drv, gen2scb);
        drv = new(vif, gen2drv, evt_capture);
        mon = new(vif, mon2scb, evt_capture);
        scb = new(gen2scb, mon2scb);
        cov = new();
    endfunction

    // run() — start all background components 
    task run();
        fork
            drv.run();   // loops forever consuming gen2drv
            mon.run();   // loops forever waiting for evt_capture
            scb.run();   // loops forever pairing gen2scb + mon2scb
        join_none
    endtask

    // -------------------------------------------------------
    // Directed-test helpers
    //   test calls: env.directed_drive(tx)  →  drives + feeds expected
    // -------------------------------------------------------
    task directed_drive(calc_transaction tx);
        // Feed expected into scoreboard pipeline BEFORE driving
        gen2scb.put(tx.copy());
        // Drive the DUT (internally triggers evt_capture)
        drv.drive(tx);
    endtask

    task press_esc();
        drv.press_esc();
    endtask
endclass
