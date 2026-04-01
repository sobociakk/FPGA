`timescale 1ns / 1ps

module calculator_fsm (
    input logic clk_i,
    input logic rst_i,
    input logic key_valid,
    input logic is_digit,
    input logic [3:0] digit_val,
    input logic is_plus,
    input logic is_minus,
    input logic is_equal,
    input logic is_esc,
    input logic [15:0] alu_result, 

    output logic [15:0] alu_arg1,
    output logic [15:0] alu_arg2,
    output logic [1:0] alu_op,
    output logic [15:0] display_val
);

    typedef enum logic [1:0] {
        ARG1 = 2'd0,
        ARG2 = 2'd1,
        RESULT = 2'd2
    } state_e;

    state_e state_q, state_d;
    logic [15:0] arg1_q, arg1_d;
    logic [15:0] arg2_q, arg2_d;
    logic [1:0] op_q, op_d;

    always_ff @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            state_q <= ARG1;
            arg1_q <= '0;
            arg2_q <= '0;
            op_q <= '0;
        end else begin
            state_q <= state_d;
            arg1_q <= arg1_d;
            arg2_q <= arg2_d;
            op_q <= op_d;
        end
    end

    always_comb begin
        state_d = state_q;
        arg1_d = arg1_q;
        arg2_d = arg2_q;
        op_d = op_q;
        display_val = '0;  

        if(key_valid && is_esc) begin
            state_d = ARG1;
            arg1_d = '0;
            arg2_d = '0;
            op_d = '0;
        end else begin
            case(state_q)
                ARG1: begin
                    display_val = arg1_q; 
                    if(key_valid) begin
                        if(is_digit) begin
                            arg1_d = {arg1_q[11:0], digit_val};
                        end else if(is_plus || is_minus) begin
                            state_d = ARG2;
                            arg2_d = '0; 
                            if(is_plus) op_d = 2'b01;
                            if(is_minus) op_d = 2'b10;
                        end
                    end
                end

                ARG2: begin
                    display_val = arg2_q; 
                    if(key_valid) begin
                        if(is_digit) begin
                            arg2_d = {arg2_q[11:0], digit_val};
                        end else if(is_equal) begin
                            state_d = RESULT;
                        end
                    end
                end

                RESULT: begin
                    display_val = alu_result; 
                    if(key_valid && is_digit) begin
                        state_d = ARG1;
                        arg1_d = {12'b0, digit_val};
                        arg2_d = '0;
                        op_d = '0;
                    end
                end
                
                default: state_d = ARG1;
            endcase
        end
    end

    assign alu_arg1 = arg1_q;
    assign alu_arg2 = arg2_q;
    assign alu_op = op_q;

endmodule