# mpsoc-osoc

mpsoc-osoc 是一个固定地址、固定总线结构的 SoC 用户处理器接入模板。用户
处理器通过简单取指/访存接口接入，MCU 从固定 `.bin` 镜像中读取 CPU ID，
经 RCU 选择实际运行的 core slot。

## 快速开始

```sh
make check
make lint
make sim CPU_ID=0
```

用户处理器放在 `user-cores/`，并在 `user-cores/cores.list` 中按顺序登记：

```text
0 UserCore0 core0/core.sv
1 UserCore1 core1/core.sv
```

slot 必须从 0 开始连续排列，最多支持 32 个 slot。`CPU_ID=N` 必须对应已
登记的用户 core；清单为空时使用内置参考 NPC。

## 用户 core 接口

每个用户模块必须实现当前 `NPC` 的简单请求/响应接口：

```text
clock, reset

io_ifu_addr       [31:0]  取指地址
io_ifu_reqValid            取指请求
io_ifu_rdata       [31:0]  取指数据
io_ifu_respValid            取指响应

io_lsu_addr       [31:0]  数据地址
io_lsu_reqValid             数据请求
io_lsu_size        [1:0]    访问大小
io_lsu_respValid            数据响应
io_lsu_rdata       [31:0]  读数据
io_lsu_wen                  写请求
io_lsu_wdata       [31:0]  写数据
io_lsu_wmask        [3:0]   字节写掩码
```

固定 `MemBridge` 会把该接口转换为 AXI。用户 core 不得直接修改或连接
AXI/APB、MCU、RCU、外设和地址译码逻辑。

## 槽位替换

`scripts/assemble-cores.py` 读取 `cores.list`，在构建目录生成：

```text
build/generated/asicTopYSYXstageDE_user.v
build/generated/user-filelist.f
```

脚本只修改构建副本中的 `NPC core0` 到 `NPC core31` 实例，仓库中的
`rtl/soc/asicTopYSYXstageDE.v` 始终保持不变。未登记的槽位继续使用参考 NPC，
但不能被用户 `CPU_ID` 选择。

## 镜像和调度

普通用户流程只使用发布包提供的：

```text
prog/hello-minirv-ysyxsoc.bin
```

`make image CPU_ID=N` 会调用既有的 `prog/change-cpuid.sh`，复制镜像并修改
其中的 CPU ID 字节。`make sim CPU_ID=N` 默认启用 MCU/RCU 调度：

```text
CPU_ID -> hello .bin -> MCU -> RCU -> coreSel -> selected slot
```

本版本不提供用户软件、驱动或 SDK 编译环境。

## 固定地址映射

地址以根目录 `mmio.h` 为准，用户不得通过 `soc_pkg` 或修改 SoC 顶层改变：

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

## 仿真和发布

常用目标：

```sh
make assemble
make lint
make sim CPU_ID=0
make trace CPU_ID=0
make export-user-kit
make clean
```

仿真产物和日志都在 `build/`，`make clean` 会删除整个目录。User Kit 只
包含固定 RTL、用户 core 模板、仿真 harness、一个 hello `.bin` 和本 README，
不包含构建产物、其他回归镜像或 SDK。

## 固定约束

- 用户不得修改 `rtl/soc/asicTopYSYXstageDE.v`。
- 用户不得修改 MCU、RCU、总线、外设和地址映射。
- 用户提交的 core 必须自行保证简单接口时序和功能正确性。
- 当前仿真完成判据依赖 `NPCTrap` 的 commit 回调；没有该回调的外部 core
  可以正常启动和执行，但会被 harness 判定为 timeout。
