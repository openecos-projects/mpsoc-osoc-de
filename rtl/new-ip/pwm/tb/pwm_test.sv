// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// pwm is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "pwm_define.svh"

class PWMTest extends APB4Master;
  string                 name;
  int                    wr_val;
  virtual apb4_if.master apb4;
  virtual pwm_if.tb      pwm;

  extern function new(string name = "pwm_test", virtual apb4_if.master apb4, virtual pwm_if.tb pwm);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_clk_div(input bit [31:0] run_times = 10);
  extern task automatic test_inc_cnt(input bit [31:0] run_times = 10);
  extern task automatic test_pwm(input bit [31:0] run_times = 1000);
  extern task automatic test_irq(input bit [31:0] run_times = 10);
endclass

function PWMTest::new(string name, virtual apb4_if.master apb4, virtual pwm_if.tb pwm);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;
  this.pwm    = pwm;
endfunction

task automatic PWMTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`PWM_CTRL_ADDR, "CTRL REG", 32'b0 & {`PWM_CTRL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PWM_PSCR_ADDR, "PSCR REG", 32'b0 & {`PWM_PSCR_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PWM_CMP_ADDR, "CMP REG", 32'b0 & {`PWM_CMP_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PWM_CR0_ADDR, "CR0 REG", 32'b0 & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PWM_CR1_ADDR, "CR1 REG", 32'b0 & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PWM_CR2_ADDR, "CR2 REG", 32'b0 & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PWM_CR3_ADDR, "CR3 REG", 32'b0 & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PWM_STAT_ADDR, "STAT REG", 32'b0 & {`PWM_STAT_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic PWMTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`PWM_CTRL_ADDR, "CTRL REG", $random & {`PWM_CTRL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PWM_CMP_ADDR, "CMP REG", $random & {`PWM_CMP_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PWM_CR0_ADDR, "CR0 REG", $random & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PWM_CR1_ADDR, "CR1 REG", $random & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PWM_CR2_ADDR, "CR2 REG", $random & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PWM_CR3_ADDR, "CR3 REG", $random & {`PWM_CRX_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic PWMTest::test_clk_div(input bit [31:0] run_times = 10);
  $display("=== [test pwm clk div] ===");
  this.write(`PWM_CTRL_ADDR, 32'b100 & {`PWM_CTRL_WIDTH{1'b1}});  // clear cnt
  this.write(`PWM_CR0_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR1_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR2_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR3_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.read(`PWM_STAT_ADDR);  // clear the irq


  repeat (200) @(posedge this.apb4.pclk);
  this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`PWM_PSCR_ADDR, 32'd3 & {`PWM_PSCR_WIDTH{1'b1}}); // div/4
  repeat (200) @(posedge this.apb4.pclk);
  this.write(`PWM_PSCR_ADDR, 32'd1 & {`PWM_PSCR_WIDTH{1'b1}}); // div/2
  repeat (200) @(posedge this.apb4.pclk);
  for (int i = 0; i < run_times; i++) begin
    this.wr_val = ($random % 20) & {`PWM_PSCR_WIDTH{1'b1}};
    this.wr_rd_check(`PWM_PSCR_ADDR, "PSCR REG", this.wr_val, Helper::EQUL);
    repeat (200) @(posedge this.apb4.pclk);
  end
endtask

task automatic PWMTest::test_inc_cnt(input bit [31:0] run_times = 10);
  $display("=== [test pwm inc cnt] ===");
  this.write(`PWM_CTRL_ADDR, 32'b100 & {`PWM_CTRL_WIDTH{1'b1}});  // clear cnt
  this.write(`PWM_CR0_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR1_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR2_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR3_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.read(`PWM_STAT_ADDR);  // clear the irq

  this.write(`PWM_CTRL_ADDR, 32'd0 & {`PWM_CTRL_WIDTH{1'b1}});
  this.write(`PWM_PSCR_ADDR, 32'd2 & {`PWM_PSCR_WIDTH{1'b1}}); // div/3
  this.write(`PWM_CMP_ADDR, 32'hF & {`PWM_CMP_WIDTH{1'b1}});
  this.write(`PWM_CTRL_ADDR, 32'b10 & {`PWM_CTRL_WIDTH{1'b1}});
  repeat (200) @(posedge this.apb4.pclk);
endtask

task automatic PWMTest::test_pwm(input bit [31:0] run_times = 1000);
  $display("=== [test pwm func] ===");
  // servo motor: 50Hz, 1~30KHz, example: 1MHz
  this.write(`PWM_CTRL_ADDR, 32'b100 & {`PWM_CTRL_WIDTH{1'b1}});  // clear cnt
  this.write(`PWM_CR0_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR1_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR2_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR3_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.read(`PWM_STAT_ADDR);  // clear the irq

  this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
  this.write(`PWM_PSCR_ADDR, 32'd9 & {`PWM_PSCR_WIDTH{1'b1}});
  this.write(`PWM_CMP_ADDR, 32'd10 & {`PWM_CMP_WIDTH{1'b1}});  // freq: 100K
  this.write(`PWM_CTRL_ADDR, 32'b10 & {`PWM_CTRL_WIDTH{1'b1}});
  // CR: [0, CMP-1] -> [10% ~ 100%]
  this.write(`PWM_CR0_ADDR, 32'd0 & {`PWM_CRX_WIDTH{1'b1}});  // 100% duty
  this.write(`PWM_CR1_ADDR, 32'd3 & {`PWM_CRX_WIDTH{1'b1}});  // 70% duty
  this.write(`PWM_CR2_ADDR, 32'd5 & {`PWM_CRX_WIDTH{1'b1}});  // 50% duty
  this.write(`PWM_CR3_ADDR, 32'd9 & {`PWM_CRX_WIDTH{1'b1}});  // 10% duty
  // @(this.pwm.pwm_o[3]);
  repeat (600) @(posedge this.apb4.pclk);
endtask

task automatic PWMTest::test_irq(input bit [31:0] run_times = 10);
  super.test_irq();
  this.write(`PWM_CTRL_ADDR, 32'b100 & {`PWM_CTRL_WIDTH{1'b1}});  // clear cnt
  this.write(`PWM_CR0_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR1_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR2_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.write(`PWM_CR3_ADDR, 32'b0 & {`PWM_CRX_WIDTH{1'b1}});
  this.read(`PWM_STAT_ADDR);  // clear the irq

  this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
  this.write(`PWM_PSCR_ADDR, 32'd3 & {`PWM_PSCR_WIDTH{1'b1}});
  this.write(`PWM_CMP_ADDR, 32'hE & {`PWM_CMP_WIDTH{1'b1}});

  for (int i = 0; i < run_times; i++) begin
    this.write(`PWM_CTRL_ADDR, 32'b0 & {`PWM_CTRL_WIDTH{1'b1}});
    this.read(`PWM_STAT_ADDR);
    $display("%t rd_data: %h", $time, super.rd_data);
    this.write(`PWM_CTRL_ADDR, 32'b11 & {`PWM_CTRL_WIDTH{1'b1}});
    @(this.pwm.irq_o);
    repeat (200) @(posedge this.apb4.pclk);
  end

endtask
