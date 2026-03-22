class rtc_test;
    rtc_env env;
    virtual rtc_if vif;

    function new(virtual rtc_if vif);
        this.vif = vif;
        this.env = new(vif); 
    endfunction

    task run();
        rtc_transaction tx;
        $display("-------------------------------------------");
        $display("--- STARTING TEST SCENARIO              ---");
        $display("-------------------------------------------");

        env.run(); 

        $display("[TEST] Fast-forwarding to 23:00...");
        repeat(23) begin
            tx = new();
            if (!tx.randomize() with { btn_hr == 1'b1; btn_min == 1'b0; btn_test == 1'b0; hold_cycles == 15; }) $fatal(1, "Rand failed");
            env.drv.drive(tx); 
        end

        repeat(200) @(posedge vif.clk);

        $display("[TEST] Fast-forwarding to 23:59...");
        repeat(59) begin
            tx = new();
            if (!tx.randomize() with { btn_hr == 1'b0; btn_min == 1'b1; btn_test == 1'b0; hold_cycles == 15; }) $fatal(1, "Rand failed");
            env.drv.drive(tx);
        end

        repeat(200) @(posedge vif.clk);

        $display("[TEST] Holding TEST button to roll over to 00:00...");
        tx = new();
        tx.btn_hr = 1'b0; tx.btn_min = 1'b0; tx.btn_test = 1'b1; tx.hold_cycles = 800;
        env.drv.drive(tx);

        repeat(200) @(posedge vif.clk);
        $display("[TEST] --- Checking Directed Scenario (00:00) ---");
        env.scb.print_final_report(4'd0, 4'd0, 4'd0, 4'd0);
        
        $display("[TEST] Starting Random Transactions...");
        repeat(100) begin
            tx = new(); 
            if (!tx.randomize()) $fatal(1, "Rand failed");
            env.drv.drive(tx);
        end
        repeat(500) @(posedge vif.clk);
        $display("[TEST] --- Checking Random Scenario Final State ---");
        env.scb.print_sanity_check();
        $finish; 
    endtask
endclass