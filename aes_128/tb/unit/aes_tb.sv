`timescale 1ns / 1ps

module aes_tb;
  import aes_pkg::*;

  logic clk;
  logic rst;
  logic [127:0] key_i;
  logic [127:0] data_i;
  logic data_write_i;
  logic [127:0] data_o;
  logic data_ready_o;

  localparam logic [127:0] AES_KEY = 128'h2b7e151628aed2a6abf7158809cf4f3c;

  aes AES (
    .clk(clk),
    .rst(rst),
    .key_i(key_i),
    .data_i(data_i),
    .data_write_i(data_write_i),
    .data_o(data_o),
    .data_ready_o(data_ready_o)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  integer fd;
  integer scan_ret;
  string line;
  int pass_cnt, fail_cnt, vec_num;

  localparam int TIMEOUT_CYCLES = 30;

  task automatic apply_reset(int cycles = 5);
    rst = 1'b1;
    data_write_i = 1'b0;
    key_i = AES_KEY;
    data_i = '0;
    repeat(cycles) @(posedge clk);
    #1;
    rst = 1'b0;
    @(posedge clk); #1;
  endtask

  task automatic encrypt_and_check(
    input logic [127:0] plain,
    input logic [127:0] exp,
    input int vec_id
  );
    int timeout;

    @(posedge clk); #1;
    data_i = plain;
    @(posedge clk); #1;
    data_write_i = 1'b1;
    @(posedge clk); #1;
    data_write_i = 1'b0;

    timeout = 0;
    while (!data_ready_o && timeout < TIMEOUT_CYCLES) begin
      @(posedge clk); #1;
      timeout++;
    end

    if (timeout >= TIMEOUT_CYCLES) begin
      $display("[VEC %0d] TIMEOUT", vec_id);
      fail_cnt++;
    end else if (data_o === exp) begin
      $display("[VEC %0d] PASS  plain=%h  cipher=%h", vec_id, plain, data_o);
      pass_cnt++;
    end else begin
      $display("[VEC %0d] FAIL  plain=%h  got=%h  expected=%h",
               vec_id, plain, data_o, exp);
      fail_cnt++;
    end
  endtask

  initial begin
    pass_cnt = 0;
    fail_cnt = 0;
    vec_num = 0;

    apply_reset();

    fd = $fopen("sim/aes_vectors.txt", "r");
    if(fd == 0)
      $fatal(1, "Cannot open file");

    while(!$feof(fd)) begin
      scan_ret = $fscanf(fd, " %s", line);
      if (scan_ret != 1) break;
      if (line.substr(0,0) == "#") begin
        if ($fgets(line, fd) == "") break;
        continue;
      end

      begin
        logic [127:0] plain_v, exp_v;
        if ($sscanf(line, "%h", plain_v) != 1) continue;
        scan_ret = $fscanf(fd, " %h", exp_v);
        if (scan_ret == 1) begin
          vec_num++;
          encrypt_and_check(plain_v, exp_v, vec_num);
        end
      end
    end

    $fclose(fd);

    $display("-----------------------------------------");
    $display("  Simulation complete: %0d PASS, %0d FAIL", pass_cnt, fail_cnt);
    $display("-----------------------------------------");
    if (fail_cnt == 0)
      $display("ALL TESTS PASSED");
    else
      $display(" %0d TEST(S) FAILED", fail_cnt);
    $finish;
  end
endmodule 
