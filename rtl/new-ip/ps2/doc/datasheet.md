## Datasheet

### Overview
The `ps2` IP is a fully parameterised soft IP implementing the IBM compatible PS/2 interface. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0. Now only support keyboard.

### Feature
* Support PS/2 keyboard only
* Configurable receive fifo depth
* Maskable fifo no-empty interrupt
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4 | interface | apb4 slave interface |
| ps2 ->| interface | ps2 slave interface |
| `ps2.ps2_clk_i` | input | ps2 clock input |
| `ps2.ps2_dat_i` | input | ps2 data input |
| `ps2.irq_o` | output | ps2 interrupt output |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL](#control-register) | 0x0 | 4 | control register |
| [DATA](#data-register) | 0x4 | 4 | data register |
| [STAT](#state-register) | 0x8 | 4 | state register |

#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:2]` | none | reserved |
| `[1:1]` | RW | EN |
| `[0:0]` | RW | ITN |

reset value: `0x0000_0000`

* EN: receive data enable
    * `EN = 1'b0`: receive data disabled
    * `EN = 1'b1`: receive data enabled

* ITN: interrupt enable
    * `ITN = 1'b0`: interrupt disabled
    * `ITN = 1'b1`: interrupt enabled

#### Data Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:8]` | none | reserved |
| `[7:0]` | RO | DATA |

reset value: `0x0000_0000`

* DATA: ps2 keyboard code

#### State Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:1]` | none | reserved |
| `[0:0]` | RO | ITF |

reset value: `0x0000_0000`

* ITF: interrupt flag

### Program Guide
These registers can be accessed by 4-byte aligned read and write. the C-like pseudocode of the init operation:
```c
ps2.CTRL.[EN, ITN] = 1 // enable receive and interrupt function

```
read keyboard code:
```c
// polling style
while(1) {
    if(ps2.STAT.ITF == 1) {
        kdb_code_8_bit = ps2.DATA // read the kdb code
    }
}

// interrupt style
ps2_interrupt_handle() {
    kdb_code_8_bit = ps2.DATA // read the kdb code
}

```
complete driver and test codes in [driver](../driver/) dir.

### Resoureces
### References
### Revision History