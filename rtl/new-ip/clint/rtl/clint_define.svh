// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// clint is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_CLINT_DEF_SV
`define INC_CLINT_DEF_SV

/* register mapping
 * CLINT_MSIP:
 * BITS:   | 31:1  | 0    |
 * FIELDS: | RES   | MSIP |
 * PERMS:  | NONE  | RW   |
 * ------------------------
 * CLINT_MTIMEL:
 * BITS:   | 31:0   |
 * FIELDS: | MTIMEL |
 * PERMS:  | RO     |
 * ------------------------
 * CLINT_MTIMEH:
 * BITS:   | 31:0   |
 * FIELDS: | MTIMEH |
 * PERMS:  | RO     |
 * ------------------------
 * CLINT_MTIMECMPL:
 * BITS:   | 31:0      |
 * FIELDS: | MTIMECMPL |
 * PERMS:  | RW        |
 * ------------------------
 * CLINT_MTIMECMPH:
 * BITS:   | 31:0      |
 * FIELDS: | MTIMECMPH |
 * PERMS:  | RW        |
 * ------------------------
*/

// verilog_format: off
`define CLINT_MSIP      14'b00_0000_0000_0000 // BASEADDR + 0x0000
`define CLINT_MTIMECMPL 14'b01_0000_0000_0000 // BASEADDR + 0x4000
`define CLINT_MTIMECMPH 14'b01_0000_0000_0001 // BASEADDR + 0x4004
`define CLINT_MTIMEL    14'b10_1111_1111_1110 // BASEADDR + 0xBFF8
`define CLINT_MTIMEH    14'b10_1111_1111_1111 // BASEADDR + 0xBFFC


`define CLINT_MSIP_ADDR      {16'b0, `CLINT_MSIP     , 2'b00}
`define CLINT_MTIMEL_ADDR    {16'b0, `CLINT_MTIMEL   , 2'b00}
`define CLINT_MTIMEH_ADDR    {16'b0, `CLINT_MTIMEH   , 2'b00}
`define CLINT_MTIMECMPL_ADDR {16'b0, `CLINT_MTIMECMPL, 2'b00}
`define CLINT_MTIMECMPH_ADDR {16'b0, `CLINT_MTIMECMPH, 2'b00}

`define CLINT_MSIP_WIDTH     1
`define CLINT_MTIME_WIDTH    64
`define CLINT_MTIMECMP_WIDTH 64

interface clint_if(input logic rtc_clk_i);
    logic  tmr_irq_o;
    logic  sfr_irq_o;
    
    modport dut(output tmr_irq_o, output sfr_irq_o);
    modport tb(input tmr_irq_o, input sfr_irq_o);
endinterface
// verilog_format: on
`endif
