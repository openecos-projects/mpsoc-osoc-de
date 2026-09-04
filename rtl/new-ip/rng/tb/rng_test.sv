// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// rng is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "rng_define.svh"

class RNGTest extends APB4Master;
  string                        name;
  int unsigned                  cnt;
  bit                    [31:0] num_qu[bit [31:0]];
  virtual apb4_if.master        apb4;

  extern function new(string name = "rng_test", virtual apb4_if.master apb4);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_gen_random_num();
endclass

function RNGTest::new(string name, virtual apb4_if.master apb4);
  super.new("apb4_master", apb4);
  this.name = name;
  this.cnt  = 0;
  this.apb4 = apb4;
endfunction

task automatic RNGTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`RNG_CTRL_ADDR, "CTRL REG", 32'b0 & {`RNG_CTRL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`RNG_VAL_ADDR, "VAL REG", 32'b0 & {`RNG_VAL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic RNGTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`RNG_CTRL_ADDR, "CTRL REG", $random & {`RNG_CTRL_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic RNGTest::test_gen_random_num();
  $display("=== [test rng gen random num] ===");

  this.write(`RNG_CTRL_ADDR, 32'b0 & {`RNG_CTRL_WIDTH{1'b1}});
  repeat (11) @(posedge this.apb4.pclk);
  this.write(`RNG_CTRL_ADDR, 32'b1 & {`RNG_CTRL_WIDTH{1'b1}});
  this.write(`RNG_SEED_ADDR, 32'h0000_FE1C & {`RNG_SEED_WIDTH{1'b1}});

  this.cnt = 0;

  do begin
    this.read(`RNG_VAL_ADDR);
    $display("%t rd_data: %d", $time, super.rd_data, this.cnt);
    if (this.num_qu.exists(super.rd_data)) begin
      $display("%t exist data: %d", $time, super.rd_data);
      break;
    end else if (cnt >= 10000) begin
      $display("%t rng test done", $time);
      break;
    end else begin
      this.num_qu[super.rd_data] = cnt;
      cnt++;
    end
  end while (1);

endtask
