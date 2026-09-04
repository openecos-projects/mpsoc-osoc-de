## Datasheet

### Overview
The `pwm(pulse width modulation)` IP is a fully parameterised soft IP to generate specific width square wave to control the average power or amplitude delivered by an electrical signal. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0.

### Feature
* 4 channels output compare with edge aligned
* Programmable prescaler
    * max division factor is up to 2^16
    * can be changed ongoing
* 16-bit programmable count up timer counter and compare register
* Auto reload counter
* Maskable overflow interrupt
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |
| pwm ->    | interface   | pwm slave interface |
| `pwm.pwm_o[4]` | output | pwm output channel |
| `pwm.irq_o` | output | interrupt output|

### Register
| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL](#control-register) | 0x0 | 4 | control register |
| [PSCR](#prescaler-reigster) | 0x4 | 4 | prescaler register |
| [CNT](#counter-reigster) | 0x8 | 4 | counter register |
| [CMP](#compare-reigster) | 0xC | 4 | compare register |
| [CR0](#channel0-reigster) | 0x10 | 4 | channel0 register |
| [CR1](#channel1-reigster) | 0x14 | 4 | channel1 register |
| [CR2](#channel2-reigster) | 0x18 | 4 | channel2 register |
| [CR3](#channel3-reigster) | 0x1C | 4 | channel3 register |
| [STAT](#state-reigster) | 0x20 | 4 | state register |


#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:3]` | none | reserved |
| `[2:2]` | RW | CLR |
| `[1:1]` | RW | EN |
| `[0:0]` | RW | OVIE |

reset value: `0x0000_0000`

* CLR: the clear signal for counter register
    * `CLR = 1'b0`: enter the normal operation mode
    * `CLR = 1'b1`: clear the value of counter register to 0

* EN: the enable signal for counter register
    * `EN = 1'b0`: counter register disabled
    * `EN = 1'b1`: counter register enabled

* OVIE: the enable signal for overflow interrupt
    * `OVIE = 1'b0`: overflow interrupt disabled
    * `OVIE = 1'b1`: overflow interrupt enabled

#### Prescaler Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | RW | PSCR |

reset value: `0x0000_0002`

* PSCR: the 16-bit prescaler value

#### Counter Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | none | CNT |

reset value: `0x0000_0000`

* CNT: the 16-bit count up register

#### Compare Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | RW | CMP |

reset value: `0x0000_0000`

* CMP: the 16-bit compare register value

#### Channel0 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | RW | CR0 |

reset value: `0x0000_0000`

* CR0: the 16-bit channel compare value

#### Channel1 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | RW | CR1 |

reset value: `0x0000_0000`

* CR1: the 16-bit channel compare value

#### Channel2 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | RW | CR2 |

reset value: `0x0000_0000`

* CR2: the 16-bit channel compare value

#### Channel3 Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:16]` | none | reserved |
| `[15:0]` | RW | CR3 |

reset value: `0x0000_0000`

* CR3: the 16-bit channel compare value

#### State Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:1]` | none | reserved |
| `[0:0]` | RO | OVIF |

reset value: `0x0000_0000`

* OVIF: the overflow interrupt flag

### Program Guide
These registers can be accessed by 4-byte aligned read and write. C-like pseudocode:

init operation:
```c
pwm.PSCR = PSC_32_bit
pwm.CMP  = COMP_32_bit  // set the compare value
pwm.CR0  = CR_32_bit    // set the channel 0 compare value
pwm.CTRL.CLR  = 1       // clear the cnt register
pwm.CTRL.CLR  = 0       // exit the clear operation
pwm.CTRL.[EN, OVIE] = 1 // enable interrupt and normal mode
```
complete driver and test codes in [driver](../driver/) dir.

### Resoureces
### References
### Revision History