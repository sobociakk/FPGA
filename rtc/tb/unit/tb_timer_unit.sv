`timescale 1ns / 1ps

module tb_timer_unit;
    parameter time CLK_PERIOD = 10;
    parameter int CYCLES_1KHZ = 10;
    parameter int TICKS_1HZ = 10;

    logic clk = 0;
    logic rst = 0;
    logic btn_test = 0;
    logic tick_1khz;
    logic tick_1hz;
    logic blink_dot;

    always #(CLK_PERIOD / 2) clk = ~clk;

    timer_unit #(.CYCLES_1KHZ(CYCLES_1KHZ), .TICKS_1HZ(TICKS_1HZ)) dut (
        .clk_i(clk),
        .rst_i(rst),
        .btn_test_i(btn_test),
        .tick_1khz_o(tick_1khz),
        .tick_1hz_o(tick_1hz),
        .blink_dot_o(blink_dot)
    );

    time exp_1khz_period = CYCLES_1KHZ * CLK_PERIOD;
    time exp_1hz_period = CYCLES_1KHZ * TICKS_1HZ * CLK_PERIOD;
    time exp_dot_half = exp_1hz_period / 2;

    initial begin
        $timeformat(-9, 0, " ns", 10);
        $display("=====================================");
        $display("--- UNIT TEST: timer_unit ---");
        $display("--- Expected 1kHz period: %t ---", exp_1khz_period);
        $display("--- Expected 1Hz period : %t ---", exp_1hz_period);
        $display("=====================================");

        btn_test = 0;
        rst = 1;
        repeat(5) @(posedge clk);
        @(negedge clk) rst = 0;
        $display("[%t] [SYS] Reset deasserted. Starting concurrent monitors.", $time);

        fork
            begin
                time t_last, t_diff;
                @(posedge tick_1khz);
                t_last = $time;
                repeat(3) begin
                    @(posedge tick_1khz);
                    t_diff = $time - t_last;
                    if (t_diff != exp_1khz_period)
                        $fatal(1, "[%t] [1KHZ_CHK] FAIL! Measured: %t | Expected: %t", $time, t_diff, exp_1khz_period);
                    else
                        $display("[%t] [1KHZ_CHK] PASS: Measured: %t | Expected: %t", $time, t_diff, exp_1khz_period);
                    t_last = $time;
                end
            end

            // THREAD 2: 1Hz Monitor
            begin
                time t_last, t_diff;
                @(posedge tick_1hz);
                t_last = $time;
                repeat(2) begin
                    @(posedge tick_1hz);
                    t_diff = $time - t_last;
                    if (t_diff != exp_1hz_period)
                        $fatal(1, "[%t] [1HZ_CHK] FAIL! Measured: %t | Expected: %t", $time, t_diff, exp_1hz_period);
                    else
                        $display("[%t] [1HZ_CHK] PASS: Measured: %t | Expected: %t", $time, t_diff, exp_1hz_period);
                    t_last = $time;
                end
            end

            // THREAD 3: Dot Monitor (50% Duty Cycle)
            begin
                time t_rise, t_fall, t_high, t_low;
                @(posedge blink_dot);
                t_rise = $time;

                @(negedge blink_dot);
                t_fall = $time;
                t_high = t_fall - t_rise;

                @(posedge blink_dot);
                t_low = $time - t_fall;

                if (t_high != exp_dot_half || t_low != exp_dot_half)
                    $fatal(1, "[%t] [DOT_CHK] FAIL! High: %t, Low: %t | Expected half: %t", $time, t_high, t_low, exp_dot_half);
                else
                    $display("[%t] [DOT_CHK] PASS: High: %t | Low: %t | Duty Cycle: 50%%", $time, t_high, t_low);
            end
        join

        // --- PHASE 3: FAST-FORWARD MODE TEST ---
        $display("----------------------------------------------------------------------");
        $display("[%t] [SYS] Forcing Fast-Forward mode (btn_test = 1)", $time);
        @(negedge clk) btn_test = 1;

        begin
            time t_last, t_diff;
            @(posedge tick_1hz);
            t_last = $time;
            repeat(3) begin
                @(posedge tick_1hz);
                t_diff = $time - t_last;
                if (t_diff != exp_1khz_period)
                    $fatal(1, "[%t] [FF_CHK] FAIL! 1Hz FF Measured: %t | Expected: %t", $time, t_diff, exp_1khz_period);
                else
                    $display("[%t] [FF_CHK] PASS: 1Hz FF Measured: %t | Expected: %t", $time, t_diff, exp_1khz_period);
                t_last = $time;
            end
        end
        $display("======================================================================");
        $display("[%t] [SYS] TESTBENCH COMPLETED SUCCESSFULLY.", $time);
        $display("======================================================================");
        $finish;
    end
endmodule