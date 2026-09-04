// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// archinfo is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "archinfo_define.svh"

class ArchInfoTest extends APB4Master;
  string                 name;
  virtual apb4_if.master apb4;

  extern function new(string name = "archinfo_test", virtual apb4_if.master apb4);
  extern task test_reset_reg();
  extern task test_wr_rd_reg(input bit [31:0] run_times = 1000);
endclass

function ArchInfoTest::new(string name, virtual apb4_if.master apb4);
  super.new("apb4_master", apb4);
  this.name = name;
  this.apb4 = apb4;
endfunction

task ArchInfoTest::test_reset_reg();
  super.test_reset_reg();
  this.rd_check(`ARCHINFO_SYS_ADDR, "SYS_VAL REG", `SYS_VAL, Helper::EQUL, Helper::INFO);
  this.rd_check(`ARCHINFO_IDL_ADDR, "IDL_VAL REG", `IDL_VAL, Helper::EQUL, Helper::INFO);
  this.rd_check(`ARCHINFO_IDH_ADDR, "IDH_VAL REG", `IDH_VAL, Helper::EQUL, Helper::INFO);
endtask

task ArchInfoTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();

  for (int i = 0; i < run_times; i++) begin
    // verilog_format: off
    this.wr_rd_check(`ARCHINFO_SYS_ADDR, "SYS_VAL REG", $random & {`ARCHINFO_SYS_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`ARCHINFO_IDL_ADDR, "IDL_VAL REG", $random & {`ARCHINFO_IDL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`ARCHINFO_IDH_ADDR, "IDH_VAL REG", $random & {`ARCHINFO_IDH_WIDTH{1'b1}}, Helper::EQUL);
    // verilog_format: on
  end

endtask
