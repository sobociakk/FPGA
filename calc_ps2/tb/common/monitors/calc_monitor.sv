class calc_monitor;
    virtual calc_if.tb vif;
    mailbox #(calc_result_tx) mon2scb;
    event evt_capture;

    function new(
        virtual calc_if.tb vif,
        mailbox #(calc_result_tx) mon2scb,
        event evt_capture
    );
        this.vif = vif;
        this.mon2scb = mon2scb;
        this.evt_capture = evt_capture;
    endfunction

    task run();
        forever begin
            @(evt_capture);
            capture_frame();
        end
    endtask

    local task capture_frame();
        logic [3:0] digit_buf[4];
        logic [3:0] seen_mask;
        logic [3:0] prev_an;
        logic [3:0] nibble;
        calc_result_tx res;

        seen_mask = 4'b0;
        prev_an = 4'hF;

        while (seen_mask != 4'b1111) begin
            @(vif.tb_cb);                                   
            if(vif.tb_cb.led7_an_o !== prev_an) begin      
                nibble = decode_seg(vif.tb_cb.led7_seg_o);
                case (vif.tb_cb.led7_an_o)
                    4'b1110: begin digit_buf[0] = nibble; seen_mask[0] = 1'b1; end
                    4'b1101: begin digit_buf[1] = nibble; seen_mask[1] = 1'b1; end
                    4'b1011: begin digit_buf[2] = nibble; seen_mask[2] = 1'b1; end
                    4'b0111: begin digit_buf[3] = nibble; seen_mask[3] = 1'b1; end
                    default: ;
                endcase
                prev_an = vif.tb_cb.led7_an_o;
            end
        end

        res = new();
        res.display_val = {digit_buf[3], digit_buf[2], digit_buf[1], digit_buf[0]};
        res.do_print();
        mon2scb.put(res);
    endtask

    local function logic [3:0] decode_seg(logic [6:0] seg);
        case (seg)
            7'b1000000: return 4'h0;
            7'b1111001: return 4'h1;
            7'b0100100: return 4'h2;
            7'b0110000: return 4'h3;
            7'b0011001: return 4'h4;
            7'b0010010: return 4'h5;
            7'b0000010: return 4'h6;
            7'b1111000: return 4'h7;
            7'b0000000: return 4'h8;
            7'b0010000: return 4'h9;
            7'b0111111: return 4'hA;   // '-' (minus sign)
            7'b0101111: return 4'hC;   // 'r' (error)
            7'b0000110: return 4'hE;   // 'E' (error)
            7'b1111111: return 4'hF;   // blank
            default:    return 4'hF;
        endcase
    endfunction
endclass
