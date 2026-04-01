class calc_driver;
    virtual calc_if vif;

    // FILTER_MAX = 2us = 200 cycles
    // half-period = 2000 cycles = 20us 
    // full byte (11 bits) = 11 * 40us = 440us << TIMEOUT_MAX (1.5ms)
    
    localparam int CLK_HALF = 2000;

    // Scan-codes 
    localparam logic [7:0] SC [14] = '{
        8'h45, 8'h16, 8'h1E, 8'h26, 8'h25,  // 0-4
        8'h2E, 8'h36, 8'h3D, 8'h3E, 8'h46,  // 5-9
        8'h79, 8'h7B, 8'h5A, 8'h76           // +, -, Enter(=), ESC
    };

    localparam int IDX_PLUS = 10;
    localparam int IDX_MINUS = 11;
    localparam int IDX_ENTER = 12;

    function new(virtual calc_if vif);
        this.vif = vif;
    endfunction

    task send_byte(logic [7:0] data);
        logic odd_parity;
        odd_parity = ~^data; 

        vif.ps2_clk <= 1'b1;
        vif.ps2_data <= 1'b1;
        repeat(CLK_HALF) @(posedge vif.clk);

        // Start bit = 0
        vif.ps2_data <= 1'b0;
        repeat(CLK_HALF) @(posedge vif.clk);
        vif.ps2_clk <= 1'b0;   // falling edge
        repeat(CLK_HALF) @(posedge vif.clk);
        vif.ps2_clk <= 1'b1;

        // data bits D0..D7 (LSB first)
        for(int i = 0; i < 8; i++) begin
            vif.ps2_data <= data[i];
            repeat(CLK_HALF) @(posedge vif.clk);
            vif.ps2_clk <= 1'b0;   
            repeat(CLK_HALF) @(posedge vif.clk);
            vif.ps2_clk <= 1'b1;
        end

        // parity bit
        vif.ps2_data <= odd_parity;
        repeat(CLK_HALF) @(posedge vif.clk);
        vif.ps2_clk <= 1'b0;
        repeat(CLK_HALF) @(posedge vif.clk);
        vif.ps2_clk <= 1'b1;

        // Stop bit = 1
        vif.ps2_data <= 1'b1;
        repeat(CLK_HALF) @(posedge vif.clk);
        vif.ps2_clk <= 1'b0;
        repeat(CLK_HALF) @(posedge vif.clk);
        vif.ps2_clk <= 1'b1;

        repeat(CLK_HALF * 2) @(posedge vif.clk);
    endtask

    // press_key — sending make code then break (F0 + code)
    // key_decoder ignore byte after F0 (state BREAK → NORMAL) 

    task press_key(logic [7:0] scan_code);
        send_byte(scan_code); // make
        send_byte(8'hF0);     // break prefix
        send_byte(scan_code); // break 
    endtask

    // enter_number 0-9999

    task enter_number(int unsigned val);
        int digits[$];  
        int tmp = val;

        if(tmp == 0) begin
            digits.push_front(0);
        end else begin
            while(tmp > 0) begin
                digits.push_front(tmp % 10); // push_front = MSD first
                tmp = tmp / 10;
            end
        end
        foreach(digits[i]) press_key(SC[digits[i]]);
    endtask
    
    task drive(calc_transaction tx);
        $display("[DRIVER] Sending: %0d %s %0d", tx.arg1, tx.op ? "-" : "+", tx.arg2);

        enter_number(tx.arg1);
        press_key(tx.op ? SC[IDX_MINUS] : SC[IDX_PLUS]);
        enter_number(tx.arg2);
        press_key(SC[IDX_ENTER]);
    endtask
endclass