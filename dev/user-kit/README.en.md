# mpsoc-osoc-de User Kit

[中文说明](README.md)

This is the user-facing environment for integrating processor cores. You only
submit your processor RTL through the fixed simple instruction/data interface.
This version does not provide a software, driver, or SDK build environment.

## Quick start

```sh
make check
make lint
make sim CPU_ID=0
```

Place cores under `user-cores/` and register them consecutively in
`user-cores/cores.list`:

```text
0 UserCore0 core0/top.sv
1 UserCore1 core1/top.sv
```

Slots must start at 0 and be consecutive, with up to 32 slots supported.
`CPU_ID=N` selects the corresponding slot. An empty list uses the bundled
reference NPC in every slot.

Each slot names one top-level source file. A multi-file core should use that
top-level file to include its other SystemVerilog sources, or place multiple
modules in one file. The top-level module name must match the second column.

## User core interface

The top-level module must implement the current NPC simple request/response
interface:

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

The fixed MemBridge converts this interface to AXI. User cores must not
connect to or modify the AXI/APB fabric, MCU, RCU, peripherals, address decoder,
or SoC top.

## Fixed address map

Use `mmio.h` as the address-map authority. Custom `soc_pkg` address spaces are
not supported in this version:

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

## Image and scheduling

Regression uses only the image shipped in the kit:

```text
prog/hello-minirv-ysyxsoc.bin
```

`make image CPU_ID=N` copies the image and calls the existing
`prog/change-cpuid.sh` to patch its CPU ID. `make sim CPU_ID=N` enables MCU/RCU
scheduling by default:

```text
CPU_ID -> hello .bin -> MCU -> RCU -> coreSel -> selected slot
```

Do not modify `prog/change-cpuid.sh`, the fixed `.bin`, the MCU, the RCU, or the
address map.

## Constraints

- Do not modify `rtl/soc/asicTopYSYXstageDE.v`.
- Do not modify the MCU, RCU, bus fabric, peripherals, or fixed address map.
- The user is responsible for simple-bus timing and functional correctness.
- Simulation PASS currently relies on the `NPCTrap` commit callback. An
  external core without that callback may run correctly, but the harness will
  report a timeout.

Simulation products and logs are written under `build/`; `make clean` removes
them. Run at least `make check` and `make lint` before submitting a user core.
