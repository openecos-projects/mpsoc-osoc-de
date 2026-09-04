// Copyright (c) 2023-2025 Yuchi Miao <miaoyuchi@ict.ac.cn>
// archinfo is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_ARCHINFO_DEF_SVH
`define INC_ARCHINFO_DEF_SVH

/* register mapping
 * ARCHINFO_SYS:
 * BITS:   | 31:20 | 19:8  | 7:0  |
 * FIELDS: | RES   | CLOCK | SRAM |
 * PERMS:  | NONE  | RW    | RW   |
 * -------------------------------------------
 * ARCHINFO_IDL:
 * BITS:   | 31:30 | 29:22  | 21:6    | 5:0  |
 * FIELDS: | TYPE  | VENDOR | PROCESS | CUST |
 * PERMS:  | RW    | RW     | RW      | RW   |
 * -------------------------------------------
 * ARCHINFO_IDH:
 * BITS:   | 31:24 | 23:0 |
 * FIELDS: | RES   | DATE |
 * PERMS:  | NONE  | RW   |
 * -------------------------------------------
*/

// verilog_format: off
`define ARCHINFO_SYS 4'b0000 // BASEADDR + 0x00
`define ARCHINFO_IDL 4'b0001 // BASEADDR + 0x04
`define ARCHINFO_IDH 4'b0010 // BASEADDR + 0x08

`define ARCHINFO_SYS_ADDR {26'b0, `ARCHINFO_SYS, 2'b00}
`define ARCHINFO_IDL_ADDR {26'b0, `ARCHINFO_IDL, 2'b00}
`define ARCHINFO_IDH_ADDR {26'b0, `ARCHINFO_IDH, 2'b00}

`define ARCHINFO_SYS_WIDTH 20
`define ARCHINFO_IDL_WIDTH 32
`define ARCHINFO_IDH_WIDTH 24

`define SYS_VAL 20'hF_1010
`define IDL_VAL 32'hFFFF_2022
`define IDH_VAL 24'hFF_FFFF
// verilog_format: on

`endif
