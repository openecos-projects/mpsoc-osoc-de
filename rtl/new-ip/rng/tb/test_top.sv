// Copyright (c) 2023-2024 Miao Yuchi <miaoyuchi@ict.ac.cn>
// rng is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
//             http://license.coscl.org.cn/MulanPSL2
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
// See the Mulan PSL v2 for more details.

`include "rng_define.svh"

program automatic test_top (
    apb4_if.master apb4
);

  string wave_name = "default.fsdb";
  task sim_config();
    $timeformat(-9, 1, "ns", 10);
    if ($test$plusargs("WAVE_ON")) begin
      $value$plusargs("WAVE_NAME=%s", wave_name);
      $fsdbDumpfile(wave_name);
      $fsdbDumpvars("+all");
    end
  endtask

  RNGTest rng_hdl;

  initial begin
    Helper::start_banner();
    sim_config();
    @(posedge apb4.presetn);
    Helper::print("tb init done");
    rng_hdl = new("rng_test", apb4);
    rng_hdl.init();
    rng_hdl.test_reset_reg();
    rng_hdl.test_wr_rd_reg();
    rng_hdl.test_gen_random_num();

    Helper::end_banner();
    #20000 $finish;
  end

endprogram
