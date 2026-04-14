`timescale 1ns / 1ps
`default_nettype none

module tb_top;
    import calc_env_pkg::*;
    logic clk;
    initial clk = 1'b0;
    always  #5 clk = ~clk;

    calc_if if_calc(.clk(clk));

  
    top #(
        .CLK_FREQ    (100_000_000),
        .CYCLES_1KHZ (1_000)
    ) DUT (
        .clk(clk),
        .btnC(if_calc.rst),
        .PS2Clk(if_calc.ps2_clk),
        .PS2Data(if_calc.ps2_data),
        .seg(if_calc.led7_seg_o),
        .an(if_calc.led7_an_o)
    );

    calc_tb tb_inst(.vif(if_calc));
endmodule

program automatic calc_tb (calc_if.tb vif);
    import calc_env_pkg::*;

    initial begin
        calc_test t;

        vif.tb_cb.ps2_clk  <= 1'b1;
        vif.tb_cb.ps2_data <= 1'b1;
        vif.tb_cb.rst      <= 1'b1;

        repeat(10) @(vif.tb_cb);

        vif.tb_cb.rst <= 1'b0;
        repeat(10) @(vif.tb_cb);

        t = new(vif);
        t.run();

        $finish;
    end
endprogram

`default_nettype wire
