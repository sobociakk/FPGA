class calc_monitor;
    virtual calc_if vif;

    mailbox #(calc_out_tx) mon2scb_mbx;

    function new(virtual calc_if vif, mailbox #(calc_out_tx) mbx);
        this.vif = vif;
        this.mon2scb_mbx = mbx;
    endfunction

    task run();
        logic [3:0] decoded_digit;
        logic [3:0] prev_anode = 4'b1111;
        calc_out_tx out_item;

        forever begin
            @(negedge vif.clk);
            if (vif.led7_an_o != prev_anode && vif.led7_an_o != 4'b1111) begin
                decoded_digit = 4'hF; 

                case(vif.led7_seg_o) 
                    7'b1000000: decoded_digit = 4'd0;
                    7'b1111001: decoded_digit = 4'd1;
                    7'b0100100: decoded_digit = 4'd2;
                    7'b0110000: decoded_digit = 4'd3;
                    7'b0011001: decoded_digit = 4'd4;
                    7'b0010010: decoded_digit = 4'd5;
                    7'b0000010: decoded_digit = 4'd6; 
                    7'b1111000: decoded_digit = 4'd7;
                    7'b0000000: decoded_digit = 4'd8;
                    7'b0010000: decoded_digit = 4'd9;
                    default: decoded_digit = 4'hF;
                endcase

                if (decoded_digit != 4'hF) begin
                    out_item = new();
                    out_item.anode = vif.led7_an_o;
                    out_item.digit_val = decoded_digit;
                    
                    mon2scb_mbx.put(out_item);
                end
                prev_anode = vif.led7_an_o;
            end
        end
    endtask 
endclass
