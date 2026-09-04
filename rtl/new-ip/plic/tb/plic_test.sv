// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_PLIC_TEST_SV
`define INC_PLIC_TEST_SV

`include "apb4_master.sv"
`include "plic_define.sv"

class PLICTest extends APB4Master;
  string                 name;
  int                    wr_val;
  virtual apb4_if.master apb4;
  virtual plic_if.tb     plic;

  extern function new(string name = "plic_test", virtual apb4_if.master apb4,
                      virtual plic_if.tb plic);
  extern task automatic test_reset_reg();
  extern task automatic test_wr_rd_reg(input bit [31:0] run_times = 1000);
  extern task automatic test_irq(input bit [31:0] run_times = 10);
endclass

function PLICTest::new(string name, virtual apb4_if.master apb4, virtual plic_if.tb plic);
  super.new("apb4_master", apb4);
  this.name   = name;
  this.wr_val = 0;
  this.apb4   = apb4;
  this.plic   = plic;
endfunction

task automatic PLICTest::test_reset_reg();
  super.test_reset_reg();
  // verilog_format: off
  this.rd_check(`PLIC_CTRL_ADDR,      "CTRL REG",      32'b0 & {`PLIC_CTRL_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_TM_ADDR,        "TM REG",        32'b0 & {`PLIC_TM_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_PRIO1_ADDR,     "PRIO1 REG",     32'b0 & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_PRIO2_ADDR,     "PRIO2 REG",     32'b0 & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_PRIO3_ADDR,     "PRIO3 REG",     32'b0 & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_PRIO4_ADDR,     "PRIO4 REG",     32'b0 & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_IP_ADDR,        "IP REG",        32'b0 & {`PLIC_IP_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_IE_ADDR,        "IE REG",        32'b0 & {`PLIC_IE_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_THOLD_ADDR,     "THOLD REG",     32'b0 & {`PLIC_THOLD_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  this.rd_check(`PLIC_CLAIMCOMP_ADDR, "CLAIMCOMP REG", 32'b0 & {`PLIC_CLAIMCOMP_WIDTH{1'b1}}, Helper::EQUL, Helper::INFO);
  // verilog_format: on
endtask

task automatic PLICTest::test_wr_rd_reg(input bit [31:0] run_times = 1000);
  super.test_wr_rd_reg();
  // verilog_format: off
  for (int i = 0; i < run_times; i++) begin
    this.wr_rd_check(`PLIC_CTRL_ADDR,  "CTRL REG",  $random & {`PLIC_CTRL_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PLIC_TM_ADDR,    "TM REG",    $random & {`PLIC_TM_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PLIC_PRIO1_ADDR, "PRIO1 REG", $random & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PLIC_PRIO2_ADDR, "PRIO2 REG", $random & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PLIC_PRIO3_ADDR, "PRIO3 REG", $random & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PLIC_PRIO4_ADDR, "PRIO4 REG", $random & {`PLIC_PRIO_WIDTH{1'b1}}, Helper::EQUL);
    this.wr_rd_check(`PLIC_IE_ADDR,    "IE REG",    ($random & {`PLIC_IE_WIDTH{1'b1}}) << 1, Helper::EQUL);
    this.wr_rd_check(`PLIC_THOLD_ADDR, "THOLD REG", $random & {`PLIC_THOLD_WIDTH{1'b1}}, Helper::EQUL);
  end
  // verilog_format: on
endtask

task automatic PLICTest::test_irq(input bit [31:0] run_times = 10);
  bit [`PLIC_PRIO_WIDTH-1:0] tmp_prio1 = 32'h7654_3211;
  bit [`PLIC_PRIO_WIDTH-1:0] tmp_prio2 = 32'hFEDC_BA98;
  bit [ `PLIC_IRQ_WIDTH-1:0] tmp_id;
  bit [ `PLIC_IRQ_WIDTH-1:0] tmp_id_arr                [6];
  bit [ `PLIC_LEV_WIDTH-1:0] tmp_prio_arr              [6];
  int                        max_prio;
  int                        max_id;
  int                        max_idx;

  super.test_irq();
  // init env
  this.write(`PLIC_CTRL_ADDR, 32'b0 & {`PLIC_CTRL_WIDTH{1'b1}});
  this.write(`PLIC_TM_ADDR, 32'b0 & {`PLIC_TM_WIDTH{1'b1}});
  this.write(`PLIC_PRIO1_ADDR, 32'b0 & {`PLIC_PRIO_WIDTH{1'b1}});
  this.write(`PLIC_PRIO2_ADDR, 32'b0 & {`PLIC_PRIO_WIDTH{1'b1}});
  this.write(`PLIC_PRIO3_ADDR, 32'b0 & {`PLIC_PRIO_WIDTH{1'b1}});
  this.write(`PLIC_PRIO4_ADDR, 32'b0 & {`PLIC_PRIO_WIDTH{1'b1}});
  this.write(`PLIC_IE_ADDR, 32'b0 & {`PLIC_IE_WIDTH{1'b1}});
  this.plic.irq_i = '0;

  // high level trigger
  this.write(`PLIC_TM_ADDR, 32'b0 & {`PLIC_TM_WIDTH{1'b1}});
  this.write(`PLIC_PRIO1_ADDR, 32'h7654_3211 & {`PLIC_PRIO_WIDTH{1'b1}});
  this.write(`PLIC_PRIO2_ADDR, 32'hFEDC_BA98 & {`PLIC_PRIO_WIDTH{1'b1}});
  this.write(`PLIC_PRIO3_ADDR, 32'h7654_3211 & {`PLIC_PRIO_WIDTH{1'b1}});
  this.write(`PLIC_PRIO4_ADDR, 32'hFEDC_BA98 & {`PLIC_PRIO_WIDTH{1'b1}});

  this.write(`PLIC_THOLD_ADDR, 32'h0 & {`PLIC_THOLD_WIDTH{1'b1}});
  this.write(`PLIC_CTRL_ADDR, 32'b1 & {`PLIC_CTRL_WIDTH{1'b1}});

  // single irq trg
  for (int i = 0; i < 1000; i++) begin
    repeat (50) @(posedge this.apb4.pclk);
    tmp_id = {$random} % 30 + 1;
    // $display("i: %d trg id: %d", i, tmp_id);
    this.write(`PLIC_IE_ADDR, (1 << tmp_id) & {`PLIC_IE_WIDTH{1'b1}});
    repeat (50) @(posedge this.apb4.pclk);
    this.plic.irq_i[tmp_id] = 1'b1;

    wait (this.plic.irq_o);
    this.read(`PLIC_CLAIMCOMP_ADDR);
    repeat (10) @(posedge this.apb4.pclk);  // sim irq handle
    this.plic.irq_i[tmp_id] = 1'b0;
    if (tmp_id != super.rd_data) begin
      $display("%t [mismatch id] trg id: %d irq id: %d", $time, tmp_id, super.rd_data);
    end
    this.write(`PLIC_CLAIMCOMP_ADDR, super.rd_data);
  end

  // multi irq trg
  for (int i = 0; i < 1000; i++) begin
    this.plic.irq_i = '0;
    tmp_id_arr      = {0, 0, 0, 0, 0, 0};
    tmp_prio_arr    = {0, 0, 0, 0, 0, 0};
    this.write(`PLIC_IE_ADDR, 32'hFFFF_FFFF & {`PLIC_IE_WIDTH{1'b1}});
    repeat (50) @(posedge this.apb4.pclk);
    for (int j = 0; j < 6; j++) begin
      tmp_id = {$random} % 29 + 1;
      if (tmp_id_arr.sum with (item == tmp_id) == 0) begin
        tmp_id_arr[j]           = tmp_id;
        // $display("tmp_id: %d", tmp_id);
        this.plic.irq_i[tmp_id] = 1'b1;
        if (tmp_id / 8 == 0 || tmp_id / 8 == 2) begin
          // $display("perip id: %d prio: %d", tmp_id, tmp_prio1[(tmp_id%8)*4+:4]);
          tmp_prio_arr[j] = tmp_prio1[(tmp_id%8)*4+:4];
        end else begin
          // $display("perip id: %d prio: %d", tmp_id, tmp_prio2[(tmp_id%8)*4+:4]);
          tmp_prio_arr[j] = tmp_prio2[(tmp_id%8)*4+:4];
        end
      end
    end

    // sort the array
    for (int j = 0; j < 5; j++) begin
      for (int k = j; k < 6; k++) begin
        if (k == j) begin
          max_idx = j;
          continue;
        end
        if ((tmp_prio_arr[k] > tmp_prio_arr[max_idx]) || (tmp_prio_arr[k] == tmp_prio_arr[max_idx] && tmp_id_arr[k] < tmp_id_arr[max_idx])) begin
          max_idx = k;
        end
      end

      // swap j, k
      max_id                = tmp_id_arr[max_idx];
      max_prio              = tmp_prio_arr[max_idx];
      tmp_id_arr[max_idx]   = tmp_id_arr[j];
      tmp_prio_arr[max_idx] = tmp_prio_arr[j];
      tmp_id_arr[j]         = max_id;
      tmp_prio_arr[j]       = max_prio;
    end

    // foreach (tmp_id_arr[i]) begin
    // $display("id_arr: %d prio_arr: %d", tmp_id_arr[i], tmp_prio_arr[i]);
    // end

    for (int j = 0; j < 6; j++) begin
      if (tmp_id_arr[j] == '0) begin
        continue;
      end
      repeat (50) @(posedge this.apb4.pclk);
      wait (this.plic.irq_o);
      this.read(`PLIC_CLAIMCOMP_ADDR);
      repeat (10) @(posedge this.apb4.pclk);  // sim irq handle
      this.plic.irq_i[tmp_id_arr[j]] = 1'b0;
      if (tmp_id_arr[j] != super.rd_data) begin
        $display("%t [mismatch id] trg id: %d irq id: %d", $time, tmp_id_arr[j], super.rd_data);
      end
      this.write(`PLIC_CLAIMCOMP_ADDR, super.rd_data);
    end
  end

endtask
`endif
