// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// clint is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "apb4_if.svh"
`include "clint_define.svh"

module apb4_clint (
`ifdef __VERILOG__
    `apb4_slave_if(apb4),
    output clint_tmr_irq_o,
    output clint_sfr_irq_o
`else
    apb4_if.slave apb4,
    clint_if.dut  clint
`endif
);

`ifndef __VERILOG__
  `apb4_slave_if2wire(apb4, apb4);
  logic clint_tmr_irq_o;
  logic clint_sfr_irq_o;
  assign clint.tmr_irq_o = clint_tmr_irq_o;
  assign clint.sfr_irq_o = clint_sfr_irq_o;
`endif

  logic [13:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`CLINT_MSIP_WIDTH-1:0] s_msip_d, s_msip_q;
  logic s_msip_en;
  logic [`CLINT_MTIME_WIDTH-1:0] s_mtime_d, s_mtime_q;
  logic s_mtime_en;
  logic [`CLINT_MTIMECMP_WIDTH-1:0] s_mtimecmp_d, s_mtimecmp_q;
  logic s_mtimecmp_en;

  assign s_apb4_addr     = apb4_paddr[15:2];
  assign s_apb4_wr_hdshk = (apb4_psel && apb4_penable) && apb4_pwrite;
  assign s_apb4_rd_hdshk = (apb4_psel && apb4_penable) && (~apb4_pwrite);
  assign apb4_pready     = 1'b1;
  assign apb4_pslverr    = 1'b0;

  assign s_msip_en = s_apb4_wr_hdshk && s_apb4_addr == `CLINT_MSIP;
  assign s_msip_d  = apb4_pwdata[`CLINT_MSIP_WIDTH-1:0];
  dffer #(`CLINT_MSIP_WIDTH) u_msip_dffer (
      apb4_pclk,
      apb4_presetn,
      s_msip_en,
      s_msip_d,
      s_msip_q
  );

  assign s_mtime_en = 1'b1;
  assign s_mtime_d  = s_mtime_q + 1'b1;
  dffer #(`CLINT_MTIME_WIDTH) u_mtime_dffer (
      apb4_pclk,
      apb4_presetn,
      s_mtime_en,
      s_mtime_d,
      s_mtime_q
  );

  assign s_mtimecmp_en = s_apb4_wr_hdshk && (s_apb4_addr == `CLINT_MTIMECMPL || s_apb4_addr == `CLINT_MTIMECMPH);
  always_comb begin
    s_mtimecmp_d = s_mtimecmp_q;
    if (s_apb4_wr_hdshk) begin
      unique case (s_apb4_addr)
        `CLINT_MTIMECMPL: s_mtimecmp_d = {s_mtimecmp_q[63:32], apb4_pwdata};
        `CLINT_MTIMECMPH: s_mtimecmp_d = {apb4_pwdata, s_mtimecmp_q[31:0]};
        default:          s_mtimecmp_d = s_mtimecmp_q;
      endcase
    end
  end
  dfferh #(`CLINT_MTIMECMP_WIDTH) u_mtimecmp_dfferh (
      apb4_pclk,
      apb4_presetn,
      s_mtimecmp_en,
      s_mtimecmp_d,
      s_mtimecmp_q
  );

  assign clint_tmr_irq_o = s_mtime_q >= s_mtimecmp_q;
  assign clint_sfr_irq_o = s_msip_q[0];

  always_comb begin
    apb4_prdata = '0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `CLINT_MSIP:      apb4_prdata[`CLINT_MSIP_WIDTH-1:0] = s_msip_q;
        `CLINT_MTIMEL:    apb4_prdata = s_mtime_q[31:0];
        `CLINT_MTIMEH:    apb4_prdata = s_mtime_q[63:32];
        `CLINT_MTIMECMPL: apb4_prdata = s_mtimecmp_q[31:0];
        `CLINT_MTIMECMPH: apb4_prdata = s_mtimecmp_q[63:32];
        default:          apb4_prdata = '0;
      endcase
    end
  end

endmodule
