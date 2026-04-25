//  calc_result_tx - Output observation transaction
//
//  Carries one complete display frame: all 4 digits decoded
//  from the 7-segment outputs into a 16-bit BCD/special value
//  Sent by calc_monitor -> calc_scb via mon2scb mailbox
//
//  Encoding matches alu.sv output:
//  [15:12] thousands | [11:8] hundreds | [7:4] tens | [3:0] units
//  Special nibbles: 4'hA='-'  4'hC='r'  4'hE='E'  4'hF=blank

class calc_result_tx;

    logic [15:0] display_val;   

    function void do_print();
        $display("[RESULT_TX] display_val = 16'h%04X", display_val);
    endfunction
endclass
