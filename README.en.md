# mpsoc-osoc

mpsoc-osoc is a fixed-address SoC template for connecting user processors. A
user core connects through the simple instruction/data request interface. The
MCU reads a CPU ID from the fixed `.bin` image, writes it to the RCU, and the
RCU releases the selected core slot from reset.

## Quick start

```sh
make check
make lint
make sim CPU_ID=0
```

Place user processors under `user-cores/` and register them consecutively in
`user-cores/cores.list`:

```text
0 UserCore0 core0/core.sv
1 UserCore1 core1/core.sv
```

Slots must start at 0 and be consecutive. Up to 32 slots are supported. A
non-empty list requires `CPU_ID=N` to refer to a registered user core. An empty
list uses the bundled reference NPC in all slots.

## User core interface

Every user module must implement the current `NPC` simple request/response
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

The fixed `MemBridge` converts this interface to AXI. User cores must not
modify or connect to the AXI/APB fabric, MCU, RCU, peripherals, or address
decoder.

## Slot assembly

`scripts/assemble-cores.py` reads `cores.list` and generates build-only files:

```text
build/generated/asicTopYSYXstageDE_user.v
build/generated/user-filelist.f
```

Only the generated copy of `NPC core0` through `NPC core31` is substituted. The
checked-in `rtl/soc/asicTopYSYXstageDE.v` is never edited. Unregistered slots use
the reference NPC and cannot be selected by a non-empty user core list.

## Image and scheduling

The public flow uses only the bundled image:

```text
prog/hello-minirv-ysyxsoc.bin
```

`make image CPU_ID=N` calls the existing `prog/change-cpuid.sh`, copies the
image, and patches its CPU ID byte. `make sim CPU_ID=N` enables MCU/RCU
scheduling by default:

```text
CPU_ID -> hello .bin -> MCU -> RCU -> coreSel -> selected slot
```

This version does not provide a software, driver, or SDK build environment.

## Fixed address map

The address map is defined by `mmio.h` and must not be changed through
`soc_pkg` or by editing the SoC top:

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

## Simulation and release

Common targets:

```sh
make assemble
make lint
make sim CPU_ID=0
make trace CPU_ID=0
make export-user-kit
make clean
```

Simulation products and logs are written under `build/`; `make clean` removes
the entire directory. The User Kit contains fixed RTL, the user core template,
the simulation harness, one hello `.bin`, and these README files. Build output,
additional regression images, and SDK sources are excluded.

## Fixed constraints

- Do not modify `rtl/soc/asicTopYSYXstageDE.v`.
- Do not modify the MCU, RCU, bus fabric, peripherals, or address map.
- The user is responsible for the timing and functional correctness of the
  submitted simple-bus core.
- The simulation PASS criterion currently relies on the `NPCTrap` commit
  callback. An external core without that callback can boot and execute, but
  the harness will report a timeout.
