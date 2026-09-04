# mpsoc-osoc-de User Kit

[English](README.en.md)

这是面向用户处理器接入的发行环境。你只需要提交自己的处理器 RTL，
通过简单取指/访存接口接入固定 SoC；本版本不提供软件、驱动或 SDK 编译环境。

## 快速开始

```sh
make check
make lint
make sim CPU_ID=0
```

将用户处理器放在 `user-cores/` 下，并在 `user-cores/cores.list` 中按槽位登记：

```text
0 UserCore0 core0/top.sv
1 UserCore1 core1/top.sv
```

槽位必须从 0 开始连续编号，最多支持 32 个槽位。`CPU_ID=N` 选择对应槽位。
清单为空时，所有槽位使用内置参考 NPC。

每个槽位登记一个顶层源文件。多文件处理器应使用这个顶层文件通过
SystemVerilog ``include` 引入其他源文件，或将多个模块放在同一个文件中。
顶层模块名必须与清单中的第二列一致。

## 用户 core 接口

顶层模块必须实现当前 NPC 简单请求/响应接口：

```text
clock, reset

io_ifu_addr       [31:0]
io_ifu_reqValid
io_ifu_rdata       [31:0]
io_ifu_respValid

io_lsu_addr       [31:0]
io_lsu_reqValid
io_lsu_size        [1:0]
io_lsu_respValid
io_lsu_rdata       [31:0]
io_lsu_wen
io_lsu_wdata       [31:0]
io_lsu_wmask        [3:0]
```

固定的 MemBridge 会将该接口转换为 AXI。用户 core 不得直接连接或修改
AXI/APB 总线、MCU、RCU、外设、地址译码逻辑或 SoC 顶层。

## 固定地址

地址以 `mmio.h` 为准，本版本不支持通过 `soc_pkg` 自定义地址空间：

| IP | Base | Length |
| --- | ---: | ---: |
| CLINT | `0x02010000` | `0x10000` |
| UART16550 | `0x10000000` | `0x8` |
| SPI | `0x10001000` | `0x20` |
| RCU | `0x10002000` | `0x1000` |
| RTC | `0x10004000` | `0x20` |
| WDG | `0x10005000` | `0x20` |
| ArchInfo | `0x10006000` | `0x10` |
| GPIO | `0x10100000` | `0x40` |
| UART | `0x10103000` | `0x20` |
| I2C | `0x10104000` | `0x20` |
| PWM | `0x10106000` | `0x40` |
| Timer 0..3 | `0x10108000..0x1010B000` | `0x20` each |
| QSPI | `0x10200000` | `0x20` |
| RNG | `0x10300000` | `0x10` |
| CRC | `0x10301000` | `0x20` |
| PSRAM | `0x80000000` | `0x400000` |

## 镜像和调度

回归固定使用发行包提供的：

```text
prog/hello-minirv-ysyxsoc.bin
```

执行 `make image CPU_ID=N` 会复制该镜像并调用已有的
`prog/change-cpuid.sh` 修改 CPU ID。`make sim CPU_ID=N` 默认启用 MCU/RCU 调度：

```text
CPU_ID -> hello .bin -> MCU -> RCU -> coreSel -> selected slot
```

用户不得修改 `prog/change-cpuid.sh`、固定 `.bin`、MCU、RCU 或地址映射。

## 约束

- 不得修改 `rtl/soc/asicTopYSYXstageDE.v`。
- 不得修改 MCU、RCU、总线、外设和固定地址映射。
- 用户负责保证 core 的简单总线时序和功能正确性。
- 仿真 PASS 依赖 `NPCTrap` 提交回调；没有该回调的外部 core 可能正常运行，
  但 harness 会报告 timeout。

仿真生成物和日志位于 `build/`，可以使用 `make clean` 删除。提交用户 core
前请至少运行 `make check` 和 `make lint`。
