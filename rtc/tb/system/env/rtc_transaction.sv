class rtc_transaction;
    rand bit btn_hr;
    rand bit btn_min;
    rand bit btn_test;
    rand int hold_cycles; 

    rand int button_choice;

    constraint c_one_button {
        button_choice dist {0 :/ 40, 1 :/ 30, 2 :/ 30, 3 :/ 0};

        (button_choice == 0) -> (btn_hr == 0 && btn_min == 0 && btn_test == 0);
        (button_choice == 1) -> (btn_hr == 1 && btn_min == 0 && btn_test == 0);
        (button_choice == 2) -> (btn_hr == 0 && btn_min == 1 && btn_test == 0);
        (button_choice == 3) -> (btn_hr == 0 && btn_min == 0 && btn_test == 1);
    }

    constraint c_hold_time {
        hold_cycles dist {[1:9] :/ 30, [10:25] :/ 70};
    }

    function void print();
        $display("[TRANSACTION] Buttons -> HR: %0b | MIN: %0b | TEST: %0b | HOLD CYCLES: %0d", btn_hr, btn_min, btn_test, hold_cycles);
    endfunction
endclass