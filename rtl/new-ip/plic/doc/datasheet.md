## Datasheet

### Overview
The `plic(platform level interrupt controller)` IP is a fully parameterised soft IP recording the SoC architecture and ASIC backend informations. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0.

### Feature
* Compatible with RISCV PLIC 1.0.0 standard
* One hart target support only
* Up to 31 external peripheral interrupt
* 16 interrupt prority levels support
* Rising edge and high level trigger types configuration
* Programmable pending counter to queue edge trigger interrupt requests
* Independent maskable and pending bit for every interrupt source
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |
| plic ->| interface | plic interface |
| `plic.irq_i` | input | plic interrupt source input |
| `plic.irq_o` | output | plic interrupt output |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL](#control-register) | 0x0 | 4 | control register |
| [TM](#trigger-mode-register) | 0x4 | 4 |  trigger mode register |
| [PRIO1](#priority-1-reigster) | 0x8 | 4 | priority 1 register |
| [PRIO2](#priority-2-reigster) | 0xC | 4 | priority 2 register |
| [PRIO3](#priority-3-reigster) | 0x10 | 4 | priority 3 register |
| [PRIO4](#priority-4-reigster) | 0x14 | 4 | priority 4 register |
| [IP](#interrupt-pend-reigster) | 0x18 | 4 | interrupt pend register |
| [IE](#interrupt-enable-reigster) | 0x1C | 4 | interrupt enable register |
| [THOLD](#interrupt-threshold-reigster) | 0x20 | 4 | interrupt threshold register |
| [CLAIMCOMP](#interrupt-claimcomplete-register) | 0x24 | 4 | interrupt claim/complete register |

#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:PLIC_GWP_WIDTH]` | none | reserved |
| `[PLIC_GWP_WIDTH-1:1]` | RW | TNM |
| `[0:0]` | RW | EN |

reset value: `0x0000_0000`

* TNM: gateway max trigger number

* EN: plic core enable
    * `EN=1'b0`: disable plic core
    * `EN=1'b1`: otherwise

#### Trigger Mode Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:31]` | RW | TM31 |
| `[30:30]` | RW | TM30 |
...
| `[1:1]` | RW | TM1 |
| `[0:0]` | RW | TM0 |

reset value: `0x0000_0000`

* TM[i]: trigger mode for irq[i]
    * `TM[i]=1'b0`: level trigger
    * `TM[i]=1'b1`: edge trigger

#### Priority 1 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:28]` | RW | PRIO7 |
...
| `[7:4]` | RW | PRIO1 |
| `[3:0]` | RW | PRIO0 |

reset value: `0x0000_0000`

* PRIO1[i]: trigger mode for irq[i]


#### Priority 2 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:28]` | RW | PRIO15 |
...
| `[7:4]` | RW | PRIO9 |
| `[3:0]` | RW | PRIO8 |

reset value: `0x0000_0000`

* PRIO1[i]: trigger mode for irq[i]


#### Priority 3 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:28]` | RW | PRIO23 |
...
| `[7:4]` | RW | PRIO17 |
| `[3:0]` | RW | PRIO16 |

reset value: `0x0000_0000`

* PRIO1[i]: trigger mode for irq[i]


#### Priority 4 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:28]` | RW | PRIO31 |
...
| `[7:4]` | RW | PRIO25 |
| `[3:0]` | RW | PRIO24 |

reset value: `0x0000_0000`

* PRIO1[i]: trigger mode for irq[i]

#### Interrupt Pend Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:31]` | RO | IP31 |
...
| `[1:1]` | RO | IP1 |
| `[0:0]` | RO | IP0 |

reset value: `0x0000_0000`

* IP[i]: interrupt pend for irq[i]

#### Interrupt Enable Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:31]` | RW | IE31 |
...
| `[1:1]` | RW | IE1 |
| `[0:0]` | RW | IE0 |

reset value: `0x0000_0000`

* IE[i]: interrupt enable for irq[i]

#### Interrupt Threshold Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:PLIC_IRQ_WIDTH]` | none | reserved |
| `[PLIC_IRQ_WIDTH-1:0]` | RW | THOLD |

reset value: `0x0000_0000`

* THOLD: interrupt trigger threshold

#### Interrupt Claim/Complete Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:PLIC_IRQ_WIDTH]` | none | reserved |
| `[PLIC_IRQ_WIDTH-1:0]` | RW | CLAIMCOMP |

reset value: `0x0000_0000`

* CLAIMCOMP: interrupt claim or comp
    * read `CLAIMCOMP` to return interrupt irq number
    * write `CLAIMCOMP` to clear interrupt irq

### Program Guide
These registers can be accessed by 4-byte aligned read and write. C-like pseudocode init operation:
```c
plic.CTRL.TNM = TNM_bit     // set the edge trigger max number
plic.TM       = TM_32_bit   // set trigger mode for irq[31-0]
plic.PRIO1    = PRO1_32_bit // set priority for irq[7-0]
plic.PRIO2    = PRO2_32_bit // set priority for irq[15-8]
plic.PRIO3    = PRO3_32_bit // set priority for irq[23-16]
plic.PRIO4    = PRO4_32_bit // set priority for irq[31-24]
plic.THOLD    = THOLD_bit   // set the trigger threshold for target 0
plic.IE       = IE_32_bit   // set interrupt enable for irq[31-0]
plic.CTRL.EN  = 1           // enable plic core

```
claim/comp operation:
```c
void plic_handle() {
    uint32_t id    = plic.CLAIMCOMP // get irq id
    ...                             // handle specified extern irq
    ...
    plic.CLAIMCOMP = id             // clear irq
}
```

### Resoureces
### References
### Revision History