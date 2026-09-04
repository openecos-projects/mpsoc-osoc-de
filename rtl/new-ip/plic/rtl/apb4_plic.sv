// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// refer to Ratified TRM: https://github.com/riscv/riscv-plic-spec/blob/master/riscv-plic-1.0.0.pdf
// now only support max 31 extern interrupt

`include "apb4_if.svh"
`include "plic_define.svh"

module apb4_plic (
`ifdef __VERILOG__
    `apb4_slave_if(apb4),
    input  [`PLIC_IRQ_NUM-1:0] plic_irq_i,
    output                     plic_irq_o
`else
    apb4_if.slave apb4,
    plic_if.dut   plic
`endif
);

`ifndef __VERILOG__
  `apb4_slave_if2wire(apb4, apb4);
  logic  [`PLIC_IRQ_NUM-1:0] plic_irq_i = plic_irq_i;
  logic plic_irq_o;
  assign plic_irq_o = plic_irq_o;
`endif

  logic [3:0] s_apb4_addr;
  logic s_apb4_wr_hdshk, s_apb4_rd_hdshk;
  logic [`PLIC_CTRL_WIDTH-1:0] s_plic_ctrl_d, s_plic_ctrl_q;
  logic s_plic_ctrl_en;
  logic [`PLIC_TM_WIDTH-1:0] s_plic_tm_d, s_plic_tm_q;
  logic s_plic_tm_en;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio1_d, s_plic_prio1_q;
  logic s_plic_prio1_en;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio2_d, s_plic_prio2_q;
  logic s_plic_prio2_en;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio3_d, s_plic_prio3_q;
  logic s_plic_prio3_en;
  logic [`PLIC_PRIO_WIDTH-1:0] s_plic_prio4_d, s_plic_prio4_q;
  logic s_plic_prio4_en;
  logic [`PLIC_IP_WIDTH-1:0] s_plic_ip_d, s_plic_ip_q;
  logic [`PLIC_IE_WIDTH-1:0] s_plic_ie_d, s_plic_ie_q;
  logic s_plic_ie_en;
  logic [`PLIC_THOLD_WIDTH-1:0] s_plic_thold_d, s_plic_thold_q;
  logic s_plic_thold_en;
  logic s_clam_in, s_comp_in;
  logic [`PLIC_LEV_WIDTH-1:0] s_prio_in [`PLIC_IRQ_NUM];
  // bit
  logic                       s_bit_en;
  logic [`PLIC_GWP_WIDTH-1:0] s_bit_tnm;
  // out
  logic [ `PLIC_IP_WIDTH-1:0] s_ip_out;
  logic [`PLIC_IRQ_WIDTH-1:0] s_id_out;


  assign s_apb4_addr     = apb4_paddr[5:2];
  assign s_apb4_wr_hdshk = apb4_psel && apb4_penable && apb4_pwrite;
  assign s_apb4_rd_hdshk = apb4_psel && apb4_penable && (~apb4_pwrite);
  assign apb4_pready     = 1'b1;
  assign apb4_pslverr    = 1'b0;

  assign s_bit_en        = s_plic_ctrl_q[0];
  assign s_bit_tnm       = s_plic_ctrl_q[`PLIC_GWP_WIDTH:1];

  assign s_plic_ctrl_en  = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_CTRL;
  assign s_plic_ctrl_d   = apb4_pwdata[`PLIC_CTRL_WIDTH-1:0];
  dffer #(`PLIC_CTRL_WIDTH) u_plic_ctrl_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_ctrl_en,
      s_plic_ctrl_d,
      s_plic_ctrl_q
  );

  assign s_plic_tm_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_TM;
  assign s_plic_tm_d  = apb4_pwdata[`PLIC_TM_WIDTH-1:0];
  dffer #(`PLIC_TM_WIDTH) u_plic_tm_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_tm_en,
      s_plic_tm_d,
      s_plic_tm_q
  );

  assign s_plic_prio1_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO1;
  assign s_plic_prio1_d  = apb4_pwdata[`PLIC_PRIO_WIDTH-1:0];
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio1_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_prio1_en,
      s_plic_prio1_d,
      s_plic_prio1_q
  );

  assign s_plic_prio2_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO2;
  assign s_plic_prio2_d  = apb4_pwdata[`PLIC_PRIO_WIDTH-1:0];
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio2_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_prio2_en,
      s_plic_prio2_d,
      s_plic_prio2_q
  );

  assign s_plic_prio3_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO3;
  assign s_plic_prio3_d  = apb4_pwdata[`PLIC_PRIO_WIDTH-1:0];
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio3_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_prio3_en,
      s_plic_prio3_d,
      s_plic_prio3_q
  );

  assign s_plic_prio4_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_PRIO4;
  assign s_plic_prio4_d  = apb4_pwdata[`PLIC_PRIO_WIDTH-1:0];
  dffer #(`PLIC_PRIO_WIDTH) u_plic_prio4_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_prio4_en,
      s_plic_prio4_d,
      s_plic_prio4_q
  );

  assign s_plic_ip_d = s_ip_out;
  dffr #(`PLIC_IP_WIDTH) u_plic_ip_dffr (
      apb4_pclk,
      apb4_presetn,
      s_plic_ip_d,
      s_plic_ip_q
  );

  assign s_plic_ie_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_IE;
  for (genvar i = 0; i < `PLIC_IRQ_NUM; i++) begin : PLIC_IE_REG_BLOCK
    if (i == 0) begin : PLIC_IE_REG0_BLOCK
      assign s_plic_ie_d[i] = 1'b0;
    end else begin : PLIC_IE_REG1_31_BLOCK
      assign s_plic_ie_d[i] = apb4_pwdata[i];
    end
  end
  dffer #(`PLIC_IE_WIDTH) u_plic_ie_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_ie_en,
      s_plic_ie_d,
      s_plic_ie_q
  );

  assign s_plic_thold_en = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_THOLD;
  assign s_plic_thold_d  = apb4_pwdata[`PLIC_THOLD_WIDTH-1:0];
  dffer #(`PLIC_THOLD_WIDTH) u_plic_thold_dffer (
      apb4_pclk,
      apb4_presetn,
      s_plic_thold_en,
      s_plic_thold_d,
      s_plic_thold_q
  );

  assign s_comp_in = s_apb4_wr_hdshk && s_apb4_addr == `PLIC_CLAIMCOMP;

  always_comb begin
    apb4_prdata = '0;
    s_clam_in   = 1'b0;
    if (s_apb4_rd_hdshk) begin
      unique case (s_apb4_addr)
        `PLIC_CTRL:  apb4_prdata[`PLIC_CTRL_WIDTH-1:0] = s_plic_ctrl_q;
        `PLIC_TM:    apb4_prdata[`PLIC_TM_WIDTH-1:0] = s_plic_tm_q;
        `PLIC_PRIO1: apb4_prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio1_q;
        `PLIC_PRIO2: apb4_prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio2_q;
        `PLIC_PRIO3: apb4_prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio3_q;
        `PLIC_PRIO4: apb4_prdata[`PLIC_PRIO_WIDTH-1:0] = s_plic_prio4_q;
        `PLIC_IP:    apb4_prdata[`PLIC_IP_WIDTH-1:0] = s_plic_ip_q;
        `PLIC_IE:    apb4_prdata[`PLIC_IE_WIDTH-1:0] = s_plic_ie_q;
        `PLIC_THOLD: apb4_prdata[`PLIC_THOLD_WIDTH-1:0] = s_plic_thold_q;
        `PLIC_CLAIMCOMP: begin
          s_clam_in                              = 1'b1;
          apb4_prdata[`PLIC_CLAIMCOMP_WIDTH-1:0] = s_id_out;
        end
        default:     apb4_prdata = '0;
      endcase
    end
  end

  // HACK: assign prio reg value with generate block
  assign s_prio_in[0] = '0;
  for (genvar i = 1; i < 32 / `PLIC_LEV_WIDTH; i++) begin : PLIC_PRIO1_ASS_BLOCK
    assign s_prio_in[i] = s_plic_prio1_q[i*4+:4];
  end

  for (genvar i = 0; i < 32 / `PLIC_LEV_WIDTH; i++) begin : PLIC_PRIO2_ASS_BLOCK
    assign s_prio_in[32/`PLIC_LEV_WIDTH*1+i] = s_plic_prio2_q[i*4+:4];
  end

  for (genvar i = 0; i < 32 / `PLIC_LEV_WIDTH; i++) begin : PLIC_PRIO3_ASS_BLOCK
    assign s_prio_in[32/`PLIC_LEV_WIDTH*2+i] = s_plic_prio3_q[i*4+:4];
  end

  for (genvar i = 0; i < 32 / `PLIC_LEV_WIDTH; i++) begin : PLIC_PRIO4_ASS_BLOCK
    assign s_prio_in[32/`PLIC_LEV_WIDTH*3+i] = s_plic_prio4_q[i*4+:4];
  end

  plic_core u_plic_core (
      .clk_i  (apb4_pclk),
      .rst_n_i(apb4_presetn),
      .tm_i   (s_plic_tm_q),
      .tnm_i  (s_bit_tnm),
      .ie_i   (s_plic_ie_q & {`PLIC_IE_WIDTH{s_bit_en}}),
      .prio_i (s_prio_in),
      .thold_i(s_plic_thold_q),
      .clam_i (s_clam_in),
      .comp_i (s_comp_in),
      .id_i   (s_comp_in ? apb4_pwdata[`PLIC_IRQ_WIDTH-1:0] : '0),
      .ip_o   (s_ip_out),
      .id_o   (s_id_out),
      .irq_i  (plic_irq_i),
      .irq_o  (plic_irq_o)
  );
endmodule
