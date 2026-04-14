`timescale 1ns / 1ps

module alu (
    input logic [15:0] alu_arg1,
    input logic [15:0] alu_arg2,
    input logic [1:0] alu_op,
    output logic [15:0] alu_result
);

    logic is_err_arg1;
    logic is_neg_arg1;
    logic signed [15:0] val1;
    logic signed [15:0] val2;
    logic signed [15:0] val_res;
    logic [13:0] res_abs;
    logic [15:0] bcd_out;

    logic [3:0] a1_3, a1_2, a1_1, a1_0;
    logic [3:0] a2_3, a2_2, a2_1, a2_0;

    assign {a1_3, a1_2, a1_1, a1_0} = alu_arg1;
    assign {a2_3, a2_2, a2_1, a2_0} = alu_arg2;

    always_comb begin
       is_err_arg1 = (alu_arg1 == 16'hFECC);
       is_neg_arg1 = (a1_3 == 4'hA) || (a1_2 == 4'hA) || (a1_1 == 4'hA);

       val1 = (a1_3 > 9 ? 0 : a1_3) * 1000 + 
              (a1_2 > 9 ? 0 : a1_2) * 100 +
              (a1_1 > 9 ? 0 : a1_1) * 10 +
              (a1_0 > 9 ? 0 : a1_0);    
       val1 = is_neg_arg1 ? -val1 : val1;

       val2 = (a2_3 > 9 ? 0 : a2_3) * 1000 + 
              (a2_2 > 9 ? 0 : a2_2) * 100 +
              (a2_1 > 9 ? 0 : a2_1) * 10 +
              (a2_0 > 9 ? 0 : a2_0);    

       if(alu_op == 2'b01) val_res = val1 + val2;
       else if(alu_op == 2'b10) val_res = val1 - val2;
       else val_res = val1;

       if(val_res < 0) res_abs = -val_res;
       else res_abs = val_res;
    end

    bin2bcd BIN2BCD(
        .bin_i(res_abs[13:0]),
        .bcd_o(bcd_out)
    );

    always_comb begin
        if (is_err_arg1 || val_res > 9999 || val_res < -999) begin
            alu_result = 16'hFECC; // Err
        end else if (val_res < 0) begin
            if (res_abs > 99) alu_result = {4'hA, bcd_out[11:0]}; // -999 -> A999
            else if (res_abs > 9) alu_result = {4'hF, 4'hA, bcd_out[7:0]}; // -99 -> FA99
            else alu_result = {4'hF, 4'hF, 4'hA, bcd_out[3:0]}; // -9 -> FFA9
        end else alu_result = bcd_out;
    end
endmodule