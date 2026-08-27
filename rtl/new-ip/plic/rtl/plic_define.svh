// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// plic is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_PLIC_DEF_SV
`define INC_PLIC_DEF_SV

/* register mapping
 * PLIC_CTRL:
 * BITS:   | 31:PLIC_GWP_WIDTH+1 | PLIC_GWP_WIDTH:1 | 0  |
 * FIELDS: | RES                 | TNM              | EN |
 * PERMS:  | NONE                | RW               | RW |
 * -------------------------------------------------------
 * PLIC_TM:
 * BITS:   | 31   | ... | 1   | 0   |
 * FIELDS: | TM31 | ... | TM1 | TM0 |
 * PERMS:  | RW   | ... | RW  | RW  |
 * -------------------------------------------------------
 * PLIC_PRIO1:
 * BITS:   | 31:28  | ... | 7:4    | 3:0    |
 * FIELDS: | PRIO7  | ... | PRIO1  | PRIO0  |
 * PERMS:  | RW     | ... | RW     | RW     |
 * -------------------------------------------------------
 * PLIC_PRIO2:
 * BITS:   | 31:28  | ... | 7:4    | 3:0    |
 * FIELDS: | PRIO15 | ... | PRIO9  | PRIO8  |
 * PERMS:  | RW     | ... | RW     | RW     |
 * -------------------------------------------------------
 * PLIC_PRIO3:
 * BITS:   | 31:28  | ... | 7:4    | 3:0    |
 * FIELDS: | PRIO23 | ... | PRIO17 | PRIO16 |
 * PERMS:  | RW     | ... | RW     | RW     |
 * -------------------------------------------------------
 * PLIC_PRIO4:
 * BITS:   | 31:28  | ... | 7:4    | 3:0    |
 * FIELDS: | PRIO31 | ... | PRIO25 | PRIO24 |
 * PERMS:  | RW     | ... | RW     | RW     |
 * -------------------------------------------------------
 * PLIC_IP:
 * BITS:   | 31   | ... | 1   | 0   |
 * FIELDS: | IP31 | ... | IP1 | IP0 |
 * PERMS:  | RO   | ... | RO  | RO  |
 * -------------------------------------------------------
 * PLIC_IE:
 * BITS:   | 31   | ... | 1   | 0   |
 * FIELDS: | IE31 | ... | IE1 | IE0 |
 * PERMS:  | RW   | ... | RW  | RW  |
 * -------------------------------------------------------
 * PLIC_THOLD:
 * BITS:   | 31:PLIC_IRQ_WIDTH | PLIC_IRQ_WIDTH-1:0 |
 * FIELDS: | RES               | THOLD              |
 * PERMS:  | NONE              | RW                 |
 * -------------------------------------------------------
 * PLIC_CLAIMCOMP:
 * BITS:   | 31:PLIC_IRQ_WIDTH | PLIC_IRQ_WIDTH-1:0 |
 * FIELDS: | RES               | CLAIMCOMP          |
 * PERMS:  | NONE              | RW                 |
 * -------------------------------------------------------
*/

// prority: 0~15
// verilog_format: off
`define PLIC_CTRL      4'b0000 // BASEADDR + 0x00
`define PLIC_TM        4'b0001 // BASEADDR + 0x04
`define PLIC_PRIO1     4'b0010 // BASEADDR + 0x08
`define PLIC_PRIO2     4'b0011 // BASEADDR + 0x0C
`define PLIC_PRIO3     4'b0100 // BASEADDR + 0x10
`define PLIC_PRIO4     4'b0101 // BASEADDR + 0x14
`define PLIC_IP        4'b0110 // BASEADDR + 0x18
`define PLIC_IE        4'b0111 // BASEADDR + 0x1C
`define PLIC_THOLD     4'b1000 // BASEADDR + 0x20
`define PLIC_CLAIMCOMP 4'b1001 // BASEADDR + 0x24

`define PLIC_CTRL_ADDR      {26'b0, `PLIC_CTRL     , 2'b00}
`define PLIC_TM_ADDR        {26'b0, `PLIC_TM       , 2'b00}
`define PLIC_PRIO1_ADDR     {26'b0, `PLIC_PRIO1    , 2'b00}
`define PLIC_PRIO2_ADDR     {26'b0, `PLIC_PRIO2    , 2'b00}
`define PLIC_PRIO3_ADDR     {26'b0, `PLIC_PRIO3    , 2'b00}
`define PLIC_PRIO4_ADDR     {26'b0, `PLIC_PRIO4    , 2'b00}
`define PLIC_IP_ADDR        {26'b0, `PLIC_IP       , 2'b00}
`define PLIC_IE_ADDR        {26'b0, `PLIC_IE       , 2'b00}
`define PLIC_THOLD_ADDR     {26'b0, `PLIC_THOLD    , 2'b00}
`define PLIC_CLAIMCOMP_ADDR {26'b0, `PLIC_CLAIMCOMP, 2'b00}

// not larger than 31+irq0
`define PLIC_IRQ_NUM    31+1
`define PLIC_PRIO_LEV   16
`define PLIC_GWP_WIDTH  3  // max gateway edge trigger counter
`define PLIC_IRQ_WIDTH  $clog2(`PLIC_IRQ_NUM)  // irq id width
`define PLIC_LEV_WIDTH  $clog2(`PLIC_PRIO_LEV)


`define PLIC_CTRL_WIDTH      4
`define PLIC_TM_WIDTH        `PLIC_IRQ_NUM
`define PLIC_PRIO_WIDTH      32
`define PLIC_IP_WIDTH        `PLIC_IRQ_NUM
`define PLIC_IE_WIDTH        `PLIC_IRQ_NUM
`define PLIC_THOLD_WIDTH     `PLIC_LEV_WIDTH
`define PLIC_CLAIMCOMP_WIDTH `PLIC_IRQ_WIDTH

`define PLIC_TM_LEVL 1'b0
`define PLIC_TM_EDGE 1'b1

// verilog_format: on

interface plic_if ();
  logic [`PLIC_IRQ_NUM-1:0] irq_i;
  logic                     irq_o;

  modport dut(input irq_i, output irq_o);
  modport tb(output irq_i, input irq_o);
endinterface

`endif
