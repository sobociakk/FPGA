`timescale 1ns / 1ps

module alu (
    input logic [15:0] alu_arg1,
    input logic [15:0] alu_arg2,
    input logic [1:0] alu_op,
    output logic [15:0] alu_result
);

    logic [13:0] bin_arg1;
    logic [13:0] bin_arg2;
    logic [14:0] bin_res;
    logic [13:0] final_res;

    always_comb begin
        bin_arg1 = (alu_arg1[15:12] * 1000) + (alu_arg1[11:8] * 100) + (alu_arg1[7:4] * 10) + alu_arg1[3:0];
        bin_arg2 = (alu_arg2[15:12] * 1000) + (alu_arg2[11:8] * 100) + (alu_arg2[7:4] * 10) + alu_arg2[3:0];

        if(alu_op == 2'b01) begin
            bin_res = bin_arg1 + bin_arg2;
        end else if(alu_op == 2'b10) begin
            if(bin_arg1 >= bin_arg2) bin_res = bin_arg1 - bin_arg2;
            else bin_res = 15'd0;
        end else bin_res = 15'd0;

        if(bin_res > 15'd9999) final_res = 14'd9999;
        else final_res = bin_res[13:0];
    end

    bin2bcd BIN2BCD(
        .bin_i(final_res),
        .bcd_o(alu_result)
    );

endmodule