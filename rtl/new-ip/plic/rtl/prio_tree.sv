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

module prio_tree #(
    parameter int LOW_IDX = 0,
    parameter int HIG_IDX = `PLIC_IRQ_NUM
) (
    input  logic [`PLIC_LEV_WIDTH-1:0] prio_i[`PLIC_IRQ_NUM],
    input  logic [`PLIC_IRQ_WIDTH-1:0] id_i  [`PLIC_IRQ_NUM],
    output logic [`PLIC_LEV_WIDTH-1:0] prio_o,
    output logic [`PLIC_IRQ_WIDTH-1:0] id_o
);

  logic [`PLIC_LEV_WIDTH-1:0] s_prio_lo, s_prio_hi;
  logic [`PLIC_IRQ_WIDTH-1:0] s_idx_lo, s_idx_hi;

  generate
    // begin
      if (HIG_IDX - LOW_IDX > 1) begin : PLIC_RECU_GEN_BLOCK
        prio_tree #(
            .LOW_IDX(LOW_IDX),
            .HIG_IDX(LOW_IDX + (HIG_IDX - LOW_IDX) / 2)
        ) u_low_prio_tree (
            prio_i,
            id_i,
            s_prio_lo,
            s_idx_lo
        );
        prio_tree #(
            .LOW_IDX(HIG_IDX - (HIG_IDX - LOW_IDX) / 2),
            .HIG_IDX(HIG_IDX)
        ) u_hig_prio_tree (
            prio_i,
            id_i,
            s_prio_hi,
            s_idx_hi
        );
      end else begin : PLIC_BOUND_GEN_BLOCK
        assign s_prio_lo = prio_i[LOW_IDX];
        assign s_prio_hi = prio_i[HIG_IDX];
        assign s_idx_lo  = id_i[LOW_IDX];
        assign s_idx_hi  = id_i[HIG_IDX];
      end
    // end
  endgenerate

  assign prio_o = s_prio_lo < s_prio_hi ? s_prio_hi : s_prio_lo;
  assign id_o   = s_prio_lo < s_prio_hi ? s_idx_hi : s_idx_lo;
endmodule
