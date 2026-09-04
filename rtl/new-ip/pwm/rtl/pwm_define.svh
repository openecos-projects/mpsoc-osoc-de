// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// pwm is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`ifndef INC_PWM_DEF_SVH
`define INC_PWM_DEF_SVH

/* register mapping
 * PWM_CTRL:
 * BITS:   | 31:3 | 2   | 1  | 0    |
 * FIELDS: | RES  | CLR | EN | OVIE |
 * PERMS:  | NONE | RW  | RW | RW   |
 * ----------------------------------
 * PWM_PSCR:
 * BITS:   | 31:16 | 15:0 |
 * FIELDS: | RES   | PSCR |
 * PERMS:  | NONE  | RW   |
 * ----------------------------------
 * PWM_CNT:
 * BITS:   | 31:16 | 15:0 |
 * FIELDS: | RES   | CNT  |
 * PERMS:  | NONE  | none |
 * ----------------------------------
 * PWM_CMP:
 * BITS:   | 31:16 | 15:0 |
 * FIELDS: | RES   | CMP  |
 * PERMS:  | NONE  | RW   |
 * ----------------------------------
 * PWM_CRX:
 * BITS:   | 31:16 | 15:0 |
 * FIELDS: | RES   | CRX  |
 * PERMS:  | NONE  | RW   |
 * ----------------------------------
 * PWM_STAT:
 * BITS:   | 31:1  | 0    |
 * FIELDS: | RES   | OVIF |
 * PERMS:  | NONE  | RO   |
 * ----------------------------------
*/

// verilog_format: off
`define PWM_CTRL 4'b0000 // BASEADDR + 0x00
`define PWM_PSCR 4'b0001 // BASEADDR + 0x04
`define PWM_CNT  4'b0010 // BASEADDR + 0x08
`define PWM_CMP  4'b0011 // BASEADDR + 0x0C
`define PWM_CR0  4'b0100 // BASEADDR + 0x10
`define PWM_CR1  4'b0101 // BASEADDR + 0x14
`define PWM_CR2  4'b0110 // BASEADDR + 0x18
`define PWM_CR3  4'b0111 // BASEADDR + 0x1C
`define PWM_STAT 4'b1000 // BASEADDR + 0x20

`define PWM_CTRL_ADDR {26'b0, `PWM_CTRL, 2'b00}
`define PWM_PSCR_ADDR {26'b0, `PWM_PSCR, 2'b00}
`define PWM_CNT_ADDR  {26'b0, `PWM_CNT , 2'b00}
`define PWM_CMP_ADDR  {26'b0, `PWM_CMP , 2'b00}
`define PWM_CR0_ADDR  {26'b0, `PWM_CR0 , 2'b00}
`define PWM_CR1_ADDR  {26'b0, `PWM_CR1 , 2'b00}
`define PWM_CR2_ADDR  {26'b0, `PWM_CR2 , 2'b00}
`define PWM_CR3_ADDR  {26'b0, `PWM_CR3 , 2'b00}
`define PWM_STAT_ADDR {26'b0, `PWM_STAT, 2'b00}

`define PWM_CTRL_WIDTH 3
`define PWM_PSCR_WIDTH 16
`define PWM_CNT_WIDTH  16
`define PWM_CMP_WIDTH  16
`define PWM_CRX_WIDTH  16
`define PWM_STAT_WIDTH 1

`define PWM_PSCR_MIN_VAL  {{(`PWM_PSCR_WIDTH-2){1'b0}}, 2'd2}
// verilog_format: on

`endif
