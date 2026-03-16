`timescale 1ns / 1ps

module tb_baud_rate_gen;
    logic clk, rst_n, tick;
    integer cycle_count = 0;

    baud_rate_gen #(
        .CLK_FREQ(100), 
        .BAUD_RATE(10)
    ) dut (
        .clk_i(clk),
        .rst_ni(rst_n),
        .tick_o(tick)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;


    always @ (posedge clk) begin 
        if(!rst_n) begin
            cycle_count <= 0;
        end else begin 
            cycle_count <= cycle_count + 1;
            if(tick == 1'b1) begin
                if(cycle_count == 9) begin
                    $display("[PASS] Tick appeared after 10 cycles");
                    cycle_count <= 0;
                end else begin
                    $fatal(1, "[FAIL] Tick appeared in wrong moment: %0d cycles", cycle_count);
                end
            end
        end
    end

    initial begin
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        rst_n = 1'b1;
        repeat(5) @(posedge tick);
        repeat(2) @(posedge clk);

        $display("[TB] Simulation completed successfully.");
        $finish;
    end

endmodule
