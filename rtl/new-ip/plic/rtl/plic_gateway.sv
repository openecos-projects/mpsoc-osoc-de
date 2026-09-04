/////////////////////////////////////////////////////////////////////
//   ,------.                    ,--.                ,--.          //
//   |  .--. ' ,---.  ,--,--.    |  |    ,---. ,---. `--' ,---.    //
//   |  '--'.'| .-. |' ,-.  |    |  |   | .-. | .-. |,--.| .--'    //
//   |  |\  \ ' '-' '\ '-'  |    |  '--.' '-' ' '-' ||  |\ `--.    //
//   `--' '--' `---'  `--`--'    `-----' `---' `-   /`--' `---'    //
//                                             `---'               //
//   RISC-V Platform-Level Interrupt Controller                    //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//                                                                 //
//             Copyright (C) 2017 ROA Logic BV                     //
//             www.roalogic.com                                    //
//                                                                 //
//   This source file may be used and distributed without          //
//   restriction provided that this copyright statement is not     //
//   removed from the file and that any derivative work contains   //
//   the original copyright notice and the associated disclaimer.  //
//                                                                 //
//      THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY        //
//   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED     //
//   TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS     //
//   FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR OR     //
//   CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,  //
//   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  //
//   NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;  //
//   LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)      //
//   HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     //
//   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR  //
//   OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS          //
//   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  //
//                                                                 //
/////////////////////////////////////////////////////////////////////
//
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "plic_define.svh"

module plic_gateway (
    input  logic                       clk_i,
    input  logic                       rst_n_i,
    input  logic                       irq_i,
    input  logic                       tm_i,
    input  logic [`PLIC_GWP_WIDTH-1:0] tnm_i,
    input  logic                       clam_i,
    input  logic                       comp_i,
    output logic                       ip_o
);

  // verilog_format:off
  localparam GW_IDLE  = 2'b00;
  localparam GW_CLAIM = 2'b01;
  localparam GW_COMP  = 2'b10;
  // verilog_format:on

  logic [1:0] s_gw_fsm_d, s_gw_fsm_q;
  logic s_irq_re_trg;
  logic s_edge_dec_d, s_edge_dec_q;
  logic [`PLIC_GWP_WIDTH-1:0] s_trg_cnt_d, s_trg_cnt_q;

  assign ip_o = s_gw_fsm_q[0];

  edge_det_sync_re #(
      .DATA_WIDTH(1)
  ) u_irq_re (
      clk_i,
      rst_n_i,
      irq_i,
      s_irq_re_trg
  );

  always_comb begin
    s_trg_cnt_d = s_trg_cnt_q;
    unique case ({
      s_edge_dec_q, s_irq_re_trg
    })
      2'b00:   s_trg_cnt_d = s_trg_cnt_q;
      2'b01: begin
        if (s_trg_cnt_q < tnm_i) begin
          s_trg_cnt_d = s_trg_cnt_q + 1'b1;
        end
      end
      2'b10: begin
        if (|s_trg_cnt_q) begin
          s_trg_cnt_d = s_trg_cnt_q - 1'b1;
        end
      end
      2'b11:   s_trg_cnt_d = s_trg_cnt_q;
      default: s_trg_cnt_d = s_trg_cnt_q;
    endcase
  end
  dffr #(`PLIC_GWP_WIDTH) u_trg_cnt_dffr (
      clk_i,
      rst_n_i,
      tm_i == `PLIC_TM_LEVL ? '0 : s_trg_cnt_d,
      s_trg_cnt_q
  );

  // flow: generate interrupt pending
  // 1. assert IP
  // 2. target 'claims IP'
  //    clears IP bit
  //    blocks IP from asserting again
  // 3. target 'completes'
  always_comb begin
    s_gw_fsm_d = s_gw_fsm_q;
    unique case (s_gw_fsm_q)
      GW_IDLE: begin
        if (tm_i == `PLIC_TM_LEVL && irq_i) begin
          s_gw_fsm_d = GW_CLAIM;
        end else if (tm_i == `PLIC_TM_EDGE && |s_trg_cnt_d) begin
          s_gw_fsm_d = GW_CLAIM;
        end
      end
      GW_CLAIM: begin
        if (clam_i) begin
          s_gw_fsm_d = GW_COMP;
        end
      end
      GW_COMP: begin
        if (comp_i) begin
          s_gw_fsm_d = GW_IDLE;
        end
      end
      default s_gw_fsm_d = GW_IDLE;
    endcase
  end
  dffr #(2) u_gp_fsm_dffr (
      clk_i,
      rst_n_i,
      s_gw_fsm_d,
      s_gw_fsm_q
  );

  assign s_edge_dec_d = (tm_i == `PLIC_TM_EDGE && |s_trg_cnt_q) ? 1'b1 : 1'b0;
  dffr #(1) u_edge_dec_dffr (
      clk_i,
      rst_n_i,
      s_edge_dec_d,
      s_edge_dec_q
  );
endmodule
