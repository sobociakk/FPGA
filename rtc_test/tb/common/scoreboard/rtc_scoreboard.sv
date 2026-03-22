class rtc_scoreboard;
    logic [3:0] last_hr_t, last_hr_u, last_min_t, last_min_u;

    mailbox #(rtc_out_tx) mon2scb_mbx;

    function new(mailbox #(rtc_out_tx) mbx);
        this.mon2scb_mbx = mbx;
    endfunction

    task run();
        rtc_out_tx item;
        $display("[SCOREBOARD] Starting comparison logic...");

        forever begin
            mon2scb_mbx.get(item);
            //item.print();
            
            if (item.digit_val != 4'hF) begin
                case (item.anode)
                    4'b1110: begin 
                        last_min_u  = item.digit_val;
                        if (item.digit_val > 9) $error("[SCOREBOARD MISMATCH] Minute units exceeded 9! Value: %0d", item.digit_val);
                        //else $display("[SCOREBOARD MATCH] Minute units OK: %0d", item.digit_val);
                    end
                    4'b1101: begin 
                        last_min_t  = item.digit_val;
                        if (item.digit_val > 5) $error("[SCOREBOARD MISMATCH] Minute tens exceeded 5! Value: %0d", item.digit_val);
                        //else $display("[SCOREBOARD MATCH] Minute tens OK: %0d", item.digit_val);
                    end
                    4'b1011: begin 
                        last_hr_u = item.digit_val;
                        if (item.digit_val > 9) $error("[SCOREBOARD MISMATCH] Hour units exceeded 9! Value: %0d", item.digit_val);
                        //else $display("[SCOREBOARD MATCH] Hour units OK: %0d", item.digit_val);
                    end
                    4'b0111: begin 
                        last_hr_t = item.digit_val;
                        if (item.digit_val > 2) $error("[SCOREBOARD MISMATCH] Hour tens exceeded 2! Value: %0d", item.digit_val);
                        //else $display("[SCOREBOARD MATCH] Hour tens OK: %0d", item.digit_val);
                    end
                endcase
            end
        end
    endtask

    function void print_final_report(logic [3:0] exp_hr_t, logic [3:0] exp_hr_u, logic [3:0] exp_min_t, logic [3:0] exp_min_u);
        $display("===========================================");
        $display("=== FINAL SCOREBOARD REPORT             ===");
        $display("===========================================");
        $display("Expected Time : %0d%0d:%0d%0d", exp_hr_t, exp_hr_u, exp_min_t, exp_min_u);
        $display("Actual Time   : %0d%0d:%0d%0d", last_hr_t, last_hr_u, last_min_t, last_min_u);
        
        if (last_hr_t == exp_hr_t && last_hr_u == exp_hr_u && last_min_t == exp_min_t && last_min_u == exp_min_u)
            $display("RESULT        : PASSED [SUCCESS]");
        else
            $display("RESULT        : FAILED [MISMATCH]");
        $display("===========================================");
    endfunction

    function void print_sanity_check();
        $display("===========================================");
        $display("=== RANDOM TEST SANITY CHECK            ===");
        $display("===========================================");
        $display("Final Random Time: %0d%0d:%0d%0d", last_hr_t, last_hr_u, last_min_t, last_min_u);
        
        if (last_hr_t <= 2 && last_hr_u <= 9 && last_min_t <= 5 && last_min_u <= 9) begin
            if (last_hr_t == 2 && last_hr_u > 3) begin
                $error("RESULT        : FAILED [INVALID HOUR > 23]");
            end else begin
                $display("RESULT        : PASSED [VALID CLOCK FORMAT]");
            end
        end else begin
            $error("RESULT        : FAILED [INVALID BCD DIGITS]");
        end
        $display("===========================================");
    endfunction

endclass