// ============================================================
//  Interface:
//    clk          : system clock (rising-edge triggered)
//    rst          : asynchronous reset, active high
//    key_i        : 128-bit encryption key
//                   (must remain stable for the entire duration
//                    of encryption — round 0 through round 10)
//    data_i       : 128-bit plaintext input
//    data_write_i : pulse high for one cycle to start
//                   a new encryption (ignored while busy)
//    data_o       : 128-bit ciphertext output
//    data_ready_o : asserted for one cycle when data_o is valid
//
//  Operation:
//    Encryption takes 11 clock cycles (round 0 to round 10)
//    - Round 0    : AddRoundKey with the original key
//    - Rounds 1–9 : SubBytes → ShiftRows → MixColumns → AddRoundKey
//    - Round 10   : SubBytes → ShiftRows →              AddRoundKey
//
//  Key schedule:
//    The KEY_GENERATION_PROC generates round keys on-the-fly,
//    one round key per clock cycle, in lock-step with the
//    encryption datapath
// ============================================================

`timescale 1ns / 1ps

module aes
  import aes_pkg::*;
(
  input logic clk,
  input logic rst,
  input logic [127:0] key_i,
  input logic [127:0] data_i,
  input logic data_write_i,
  output logic [127:0] data_o,
  output logic data_ready_o
);

  logic [127:0] state;
  logic data_ready;
  logic calculating_data;
  logic [3:0] round;        
  logic start_condition;

  // Round-key words 
  logic [31:0] key_w0, key_w1, key_w2, key_w3;
  logic [127:0] round_key;

  assign data_o = state;
  assign data_ready_o = data_ready;
  assign round_key = {key_w0, key_w1, key_w2, key_w3};
  assign start_condition = data_write_i & ~calculating_data;

  always_ff @(posedge clk or posedge rst) begin : ENCRYPTION_PROC

    logic [127:0] sv1, sv2, sv3, sv4;   // state variable

    if(rst) begin
      round <= '0;
      data_ready <= 1'b0;
      calculating_data <= 1'b0;
      state <= '0;
    end else begin
      if(start_condition) begin
        // Round 0: load data and XOR with original key 
        round <= 4'd1;
        data_ready <= 1'b0;
        calculating_data <= 1'b1;
        state <= data_i ^ key_i;

      end else if(calculating_data) begin
        // SubBytes
        sv1 = sub_bytes(state);

        // ShiftRows
        sv2 = shift_rows(sv1);

        // MixColumns (skipped in final round 10)
        sv3 = (round <= 4'd9) ? mix_columns(sv2) : sv2;

        // AddRoundKey
        sv4 = sv3 ^ round_key;

        // Write back
        state <= sv4;

        if(round == 4'd10) begin
          data_ready <= 1'b1;
          calculating_data <= 1'b0;
          round <= '0;
        end else begin
          round <= round + 4'd1;
        end
      end
    end
  end : ENCRYPTION_PROC

  // ==================================================================
  //  KEY_GENERATION_PROC — AES-128 key schedule
  //
  //  Produces one new round key per clock cycle, always one step
  //  ahead of the encryption datapath. The schedule is reset to
  //  the original key whenever the core is idle or just finished
  //  round 10, ready for the next encryption request
  // ==================================================================
  always_ff @(posedge clk or posedge rst) begin : KEY_GENERATION_PROC

    logic [31:0] key_tmp, w4, w5, w6, w7;

    if(rst) begin
      key_w0 <= '0;
      key_w1 <= '0;
      key_w2 <= '0;
      key_w3 <= '0;
    end else begin
      // Load original key when idle (round==0 and not starting)
      // or immediately after the last round so it is ready for the next encryption 
      if((round == 4'd0 && ~start_condition) || (round == 4'd10)) begin
        key_w0 <= key_i[127:96];
        key_w1 <= key_i[95:64];
        key_w2 <= key_i[63:32];
        key_w3 <= key_i[31:0];
      end else begin
        // Key expansion 
        key_tmp = sub_word(rot_word(key_w3)) ^ {rcon(round + 1), 24'h000000};
        w4 = key_tmp ^ key_w0;
        w5 = w4 ^ key_w1;
        w6 = w5 ^ key_w2;
        w7 = w6 ^ key_w3;

        key_w0 <= w4;
        key_w1 <= w5;
        key_w2 <= w6;
        key_w3 <= w7;
      end
    end
  end : KEY_GENERATION_PROC

endmodule : aes
