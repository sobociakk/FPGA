//  key: 2b7e1516_28aed2a6_abf71588_09cf4f3c
//
//  How to observe output:
//    1. Set SW[7:0] to desired plaintext byte
//    2. Press BTNC once → starts encryption
//    3. LD16 lights up when done
//    4. LED[15:0] shows data_o[15:0]
//    5. Compare LED[7:0] with simulation result for the same input
// ============================================================

`timescale 1ns / 1ps

module aes_basys3
  import aes_pkg::*;
(
  input logic clk,        
  input logic [7:0] sw,         
  input logic btnc,       
  output logic [15:0] led,       
  output logic led16_b     
);

  localparam logic [127:0] AES_KEY = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;

  logic rst;
  logic [127:0] data_i;
  logic [127:0] data_o_int;
  logic data_ready;
  logic data_write;

  assign rst = 1'b0;
  assign data_i = {120'b0, sw};

  logic btnc_s0, btnc_s1, btnc_s2;   

  always_ff @(posedge clk) begin
    btnc_s0 <= btnc;
    btnc_s1 <= btnc_s0;
    btnc_s2 <= btnc_s1;
  end

  // Rising edge
  assign data_write = btnc_s1 & ~btnc_s2;

  aes AES (
    .clk(clk),
    .rst(rst),
    .key_i(AES_KEY),
    .data_i(data_i),
    .data_write_i(data_write),
    .data_o(data_o_int),
    .data_ready_o(data_ready)
  );

  assign led = data_o_int[15:0];
  assign led16_b = data_ready;

endmodule : aes_basys3
