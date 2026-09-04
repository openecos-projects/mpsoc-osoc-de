// vim: ts=4 sw=4 expandtab

// THIS IS GENERATED VERILOG CODE.
// https://bues.ch/h/crcgen
// 
// This code is Public Domain.
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted.
// 
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
// SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER
// RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
// NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE
// USE OR PERFORMANCE OF THIS SOFTWARE.
//
// -- Adaptable modifications are redistributed under compatible License --
//
// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// crc is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

// CRC polynomial coefficients: x^8 + x^2 + x + 1
//                              0x7 (hex)
// CRC width:                   8 bits
// CRC shift direction:         left (big endian)
// Input word width:            8 bits

module crc8_07 (
    input  [7:0] data_i,
    input  [7:0] crc_i,
    output [7:0] crc_o
);

  assign crc_o[0] = crc_i[0] ^ crc_i[6] ^ crc_i[7] ^ data_i[0] ^ data_i[6] ^ data_i[7];
  assign crc_o[1] = crc_i[0] ^ crc_i[1] ^ crc_i[6] ^ data_i[0] ^ data_i[1] ^ data_i[6];
  assign crc_o[2] = crc_i[0] ^ crc_i[1] ^ crc_i[2] ^ crc_i[6] ^ data_i[0] ^ data_i[1] ^ data_i[2] ^ data_i[6];
  assign crc_o[3] = crc_i[1] ^ crc_i[2] ^ crc_i[3] ^ crc_i[7] ^ data_i[1] ^ data_i[2] ^ data_i[3] ^ data_i[7];
  assign crc_o[4] = crc_i[2] ^ crc_i[3] ^ crc_i[4] ^ data_i[2] ^ data_i[3] ^ data_i[4];
  assign crc_o[5] = crc_i[3] ^ crc_i[4] ^ crc_i[5] ^ data_i[3] ^ data_i[4] ^ data_i[5];
  assign crc_o[6] = crc_i[4] ^ crc_i[5] ^ crc_i[6] ^ data_i[4] ^ data_i[5] ^ data_i[6];
  assign crc_o[7] = crc_i[5] ^ crc_i[6] ^ crc_i[7] ^ data_i[5] ^ data_i[6] ^ data_i[7];
endmodule
