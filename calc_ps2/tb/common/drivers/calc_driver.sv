class calc_driver;
    virtual calc_if.tb vif;
    mailbox #(calc_transaction) gen2drv;
    event evt_capture;   

    localparam int CLK_HALF = 2000;   

    localparam logic [7:0] SC[14] = '{
        8'h45, 8'h16, 8'h1E, 8'h26, 8'h25,   // 0-4
        8'h2E, 8'h36, 8'h3D, 8'h3E, 8'h46,   // 5-9
        8'h79, 8'h7B, 8'h5A, 8'h76           // +, -, Enter, ESC
    };
    localparam int IDX_PLUS = 10;
    localparam int IDX_MINUS = 11;
    localparam int IDX_ENTER = 12;
    localparam int IDX_ESC = 13;

    function new(
        virtual calc_if.tb vif,
        mailbox #(calc_transaction) gen2drv,
        event evt_capture
    );
        this.vif = vif;
        this.gen2drv = gen2drv;
        this.evt_capture = evt_capture;
    endfunction

    task run();
        calc_transaction tx;
        forever begin
            gen2drv.get(tx);
            drive(tx);
        end
    endtask
    
    task drive(calc_transaction tx);
        $display("[DRV] Driving: %0d %0s %0d", tx.arg1, tx.op ? "-" : "+", tx.arg2);
        enter_number(tx.arg1);
        press_key(tx.op ? SC[IDX_MINUS] : SC[IDX_PLUS]);
        enter_number(tx.arg2);
        press_key(SC[IDX_ENTER]);
        -> evt_capture;
    endtask

    task press_esc();
        press_key(SC[IDX_ESC]);
    endtask

    local task send_byte(logic [7:0] data);
        logic odd_parity;
        odd_parity = ~^data;

        // Idle line
        vif.tb_cb.ps2_clk <= 1'b1;
        vif.tb_cb.ps2_data <= 1'b1;
        repeat(CLK_HALF) @(vif.tb_cb);

        // Start bit (low)
        vif.tb_cb.ps2_data <= 1'b0;
        repeat(CLK_HALF) @(vif.tb_cb);
        vif.tb_cb.ps2_clk <= 1'b0;
        repeat(CLK_HALF) @(vif.tb_cb);
        vif.tb_cb.ps2_clk <= 1'b1;

        // D0..D7 LSB-first
        for (int i = 0; i < 8; i++) begin
            vif.tb_cb.ps2_data <= data[i];
            repeat(CLK_HALF) @(vif.tb_cb);
            vif.tb_cb.ps2_clk <= 1'b0;
            repeat(CLK_HALF) @(vif.tb_cb);
            vif.tb_cb.ps2_clk <= 1'b1;
        end

        // Parity bit (odd)
        vif.tb_cb.ps2_data <= odd_parity;
        repeat(CLK_HALF) @(vif.tb_cb);
        vif.tb_cb.ps2_clk  <= 1'b0;
        repeat(CLK_HALF) @(vif.tb_cb);
        vif.tb_cb.ps2_clk <= 1'b1;

        // Stop bit (high)
        vif.tb_cb.ps2_data<= 1'b1;
        repeat(CLK_HALF) @(vif.tb_cb);
        vif.tb_cb.ps2_clk <= 1'b0;
        repeat(CLK_HALF) @(vif.tb_cb);
        vif.tb_cb.ps2_clk <= 1'b1;

        // Inter-byte gap
        repeat(CLK_HALF * 2) @(vif.tb_cb);
    endtask

    local task press_key(logic [7:0] scan_code);
        send_byte(scan_code);   // make
        send_byte(8'hF0);       // break prefix
        send_byte(scan_code);   // break repeat
    endtask

    local task enter_number(int unsigned val);
        int digits[$];
        int tmp = val;
        if(tmp == 0) digits.push_front(0);
        else while(tmp > 0) begin
            digits.push_front(tmp % 10);
            tmp = tmp / 10;
        end
        foreach(digits[i]) press_key(SC[digits[i]]);
    endtask

endclass