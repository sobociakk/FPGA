class calc_generator;
    mailbox #(calc_transaction) gen2drv;
    mailbox #(calc_transaction) gen2scb;
    int unsigned num_transactions;

    function new(
        mailbox #(calc_transaction) gen2drv,
        mailbox #(calc_transaction) gen2scb,
        int unsigned num = 20
    );
        this.gen2drv = gen2drv;
        this.gen2scb = gen2scb;
        this.num_transactions = num;
    endfunction

    task run();
        calc_transaction tx;
        $display("[GEN] Starting: %0d random transactions", num_transactions);

        repeat (num_transactions) begin
            tx = new();
            if(!tx.randomize()) $fatal(1, "[GEN] Randomization FAILED");
            tx.do_print("GEN");
            gen2drv.put(tx.copy());
            gen2scb.put(tx.copy());
        end

        $display("[GEN] Done (%0d transactions generated)", num_transactions);
    endtask
endclass
