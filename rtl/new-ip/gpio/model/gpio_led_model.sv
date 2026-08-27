// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// gpio is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

module gpio_led_model #(
    parameter int GPIO_NUM = 32
) (
    input logic [GPIO_NUM-1:0] led_i
);

  always @(led_i) begin
    for (integer i = 0; i < GPIO_NUM; i++) begin
      if (led_i[i]) begin
        $display("[GPIO] led %d triggered", i);
      end
    end
  end
endmodule
