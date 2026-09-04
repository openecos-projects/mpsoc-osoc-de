// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// pwm is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

interface pwm_if ();
  logic [3:0] pwm_o;
  logic       irq_o;

  modport dut(output pwm_o, output irq_o);
  modport tb(input pwm_o, input irq_o);
endinterface