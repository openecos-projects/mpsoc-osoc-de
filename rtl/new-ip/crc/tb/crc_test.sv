// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// crc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_CRC_TEST_SV
`define INC_CRC_TEST_SV

`include "apb4_master.sv"
`include "crc_define.sv"

class CRCTest extends APB4Master;
  string                 name;
  int                    wr_val;
  int                    crc16_8005_arc_data    [256];
  int                    crc16_8005_buypass_data[256];
  virtual apb4_if.master apb4;


  extern function new(string name = "crc_test", virtual apb4_if.master apb4);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_gen_lut();
  extern task automatic test_crc8_simple();
  extern task automatic test_crc16_simple();
  extern task automatic test_crc32_simple();
  extern task automatic test_stat();
  extern task automatic test_crc();

endclass

function CRCTest::new(string name, virtual apb4_if.master apb4);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;

endfunction

task automatic CRCTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`CRC_CTRL_ADDR, "CTRL REG", 32'b0 & {`CRC_CTRL_WIDTH{1'b1}}, Helper::EQUL);
  this.rd_check(`CRC_INIT_ADDR, "INIT REG", 32'b0 & {`CRC_INIT_WIDTH{1'b1}}, Helper::EQUL);
  this.rd_check(`CRC_XORV_ADDR, "XORV REG", 32'b0 & {`CRC_XORV_WIDTH{1'b1}}, Helper::EQUL);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'b0 & {`CRC_DATA_WIDTH{1'b1}}, Helper::EQUL);
  this.rd_check(`CRC_STAT_ADDR, "STAT REG", 32'b0 & {`CRC_INIT_WIDTH{1'b1}}, Helper::EQUL);
  // verilog_format: on
endtask

task automatic CRCTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`CRC_CTRL_ADDR, "CTRL REG", $random & {`CRC_CTRL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`CRC_INIT_ADDR, "INIT REG", $random & {`CRC_INIT_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`CRC_XORV_ADDR, "XORV REG", $random & {`CRC_XORV_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic CRCTest::test_crc8_simple();
  $display("%t === [test gen crc8] ===", $time);
  // CRC-8/I-432-1
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h55 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h2B, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hA4, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h29, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h49, Helper::EQUL);

  // CRC-8/ROHC
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_00_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h30, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_00_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h07, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_00_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hFD, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_00_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h76, Helper::EQUL);


  // CRC-8/ROHC
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h7E, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF1, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h7C, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_00_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1C, Helper::EQUL);
endtask

task automatic CRCTest::test_crc16_simple();
  $display("%t === [test gen crc16] ===", $time);

  // CRC-16/GENIBUS 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h2C7C, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF136, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hED02, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCF13, Helper::EQUL);

  // CRC-16/GSM 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCD8C, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hEC39, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h219E, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h4BD3, Helper::EQUL);

  // CRC-16/IBM-3740 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD383, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h0EC9, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h12FD, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h30EC, Helper::EQUL);

  // CRC-16/IBM-SDLC 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hC3EB, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hDEC1, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1090, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h9B2E, Helper::EQUL);

  // CRC-16/ISO-IEC-14443-3-A 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hC6C6 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h626D, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCF26, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h7348, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h31F0, Helper::EQUL);

  // CRC-16/KERMIT 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h3393, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD186, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD65C, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h67F0, Helper::EQUL);

  // CRC-16/MCRF4XX 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h3C14, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h213E, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hEF6F, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h64D1, Helper::EQUL);

  // CRC-16/RIELLO 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hB2AA & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hAA27, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h22B0, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h821A, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h4096, Helper::EQUL);

  // CRC-16/SPI-FUJITSU 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h1D0F & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hFEEF, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h9706, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCF6D, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hBA3C, Helper::EQUL);

  // CRC-16/TMS37157 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h89EC & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hB6A4, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h943F, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hFE53, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h9F2F, Helper::EQUL);

  // CRC-16/XMODEM 1021
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h3273, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h13C6, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hDE61, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_01_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hB42C, Helper::EQUL);

  // CRC-16/ARC 8005
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h0D80, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h770D, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hFB36, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h347B, Helper::EQUL);

  // CRC-16/CMS 8005
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hFD6E, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h6CB6, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hB69C, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1EA7, Helper::EQUL);

  // CRC-16/DDS-110 8005
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h800D & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h8E6F, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hEC9F, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1C9F, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1E5B, Helper::EQUL);

  // CRC-16/MAXIM-DOW 8005
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF27F, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h88F2, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h04C9, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCB84, Helper::EQUL);

  // CRC-16/MODBUS 8005
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h4D3F, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hC70C, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h3B47, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h107B, Helper::EQUL);

  // CRC-16/UMTS 8005
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h006C, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hECBB, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h389F, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_10_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1E83, Helper::EQUL);

  // CRC-16/USB 8005
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hB2C0, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h38F3, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hC4B8, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hEF84, Helper::EQUL);
endtask

task automatic CRCTest::test_crc32_simple();
  $display("%t === [test gen crc32] ===", $time);

  // CRC-32/BZIP2
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF_FFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF_FFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF464A055, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h88DD85D2, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h416779A8, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h207575D4, Helper::EQUL);

  // CRC-32/CKSUM
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'h0 & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF_FFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hBA6C1FE1, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h886AE1AF, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF60304A8, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hE771A8AF, Helper::EQUL);

  // CRC-32/ISO-HDLC
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF_FFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF_FFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h21BB9EC5, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h18999699, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD9C1A93A, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h4A090E98, Helper::EQUL);

  // CRC-32/JAMCRC
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF_FFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hDE44613A, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hE7666966, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h263E56C5, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_11_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hB5F6F167, Helper::EQUL);

  // CRC-32/MPEG-2
  // 8Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF_FFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'h0 & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h0B9B5FAA, Helper::EQUL);
  // 16Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b01_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h77227A2D, Helper::EQUL);
  // 24Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b10_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h123456 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hBE988657, Helper::EQUL);
  // 32Bits
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_CTRL_ADDR, 32'b11_11_0_0_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hDF8A8A2B, Helper::EQUL);
endtask

task automatic CRCTest::test_stat();
  $display("%t === [test stat] ===", $time);

  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  this.write(`CRC_CTRL_ADDR, 32'b00_10_1_1_1 & {`CRC_CTRL_WIDTH{1'b1}});
  repeat (100) @(posedge this.apb4.pclk);
  this.write(`CRC_DATA_ADDR, 32'h12 & {`CRC_DATA_WIDTH{1'b1}});

  do begin
    this.read(`CRC_STAT_ADDR);
    if (super.rd_data[0] == 1'b1) break;
  end while (1);

  this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hB2C0, Helper::EQUL);
endtask

task automatic CRCTest::test_crc();
  $display("=== [test crc8 val] ===");
  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b000001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h4 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h1C, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'h55 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b000001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD9, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b001101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h4 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hC8, Helper::EQUL);

  // $display("=== [test crc16 0x1021 val] ===");
  // this.write(`CRC_INIT_ADDR, 32'h1D0F & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h9706, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h0EC9, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hF136, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hD186, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h213E, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hB2AA & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h22B0, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'h89EC & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h943F, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hDEC1, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b010001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h13C6, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hC6C6 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b011101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hCF26, Helper::EQUL);

  // $display("=== [test crc16 0x8005 val] ===");
  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b000_0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b010_1101 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   if (this.crc16_8005_arc_data[i] - super.rd_data != 0) begin
  //     $display("%t %d expt: %h actu: %h", $time, i, this.crc16_8005_arc_data[i], super.rd_data);
  //   end
  // end

  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b10_1101 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   if (this.crc16_8005_buypass_data[i] - super.rd_data != 0) begin
  //     $display("%t %d expt: %h actu: %h", $time, i, this.crc16_8005_buypass_data[i], super.rd_data);
  //   end
  // end

  // NOTE:
  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'h800D & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b10_0001 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   $display("%t %d expt: %h", $time, i, super.rd_data);
  // end

  // this.write(`CRC_INIT_ADDR, 32'h800D & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b100001 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hEC9F, Helper::EQUL);


  // this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b101101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h88F2, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b101101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h1234 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'hC70C, Helper::EQUL);

  // this.write(`CRC_INIT_ADDR, 32'hFFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b101101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'hE3A4 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h6841, Helper::EQUL);

  // $display("=== [test crc32 val] ===");
  // this.write(`CRC_INIT_ADDR, 32'hFFFF_FFFF & {`CRC_INIT_WIDTH{1'b1}});
  // this.write(`CRC_XORV_ADDR, 32'hFFFF_FFFF & {`CRC_XORV_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  // this.write(`CRC_CTRL_ADDR, 32'b111101 & {`CRC_CTRL_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.write(`CRC_DATA_ADDR, 32'h12345678 & {`CRC_DATA_WIDTH{1'b1}});
  // repeat (200) @(posedge this.apb4.pclk);
  // this.rd_check(`CRC_DATA_ADDR, "DATA REG", 32'h4A090E98, Helper::EQUL);

  // for (int i = 0; i < 256; i++) begin
  //   this.write(`CRC_INIT_ADDR, 32'b0 & {`CRC_INIT_WIDTH{1'b1}});
  //   this.write(`CRC_XORV_ADDR, 32'b0 & {`CRC_XORV_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b0010 & {`CRC_CTRL_WIDTH{1'b1}});
  //   this.write(`CRC_CTRL_ADDR, 32'b11_0001 & {`CRC_CTRL_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.write(`CRC_DATA_ADDR, i & {`CRC_DATA_WIDTH{1'b1}});
  //   repeat (200) @(posedge this.apb4.pclk);
  //   this.read(`CRC_DATA_ADDR);
  //   $display("%t %d expt: %h", $time, i, super.rd_data);
  // end

endtask

`endif
