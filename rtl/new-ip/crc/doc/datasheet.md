## Datasheet

### Overview
The `crc` IP is a fully parameterised soft IP recording the SoC architecture and ASIC backend informations. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0. 

### Feature
* Max 32-bit CRC code calculation
* Multiple CRC polynomials support
    * CRC8  - 0x07
    * CRC16 - 0x1021
    * CRC16 - 0x8005
    * CRC32 - 0x04c11db7
* Input byte reverse support
* Output bit reverse support
* Programmable init data register and ouput XOR data register
* Internal LFSR technique implementation
* 1~4 APB4 clock cycle calculation peroid
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [CTRL](#control-register) | 0x0 | 4 | control register |
| [INIT](#init-value-reigster) | 0x4 | 4 | init value register |
| [XORV](#xor-value-reigster) | 0x8 | 4 | xor value register |
| [DATA](#data-reigster) | 0xC | 4 | data register |
| [STAT](#state-reigster) | 0x10 | 4 | state register |

#### Control Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:7]` | none | reserved |
| `[6:5]` | RW | SIZE |
| `[4:3]` | RW | MODE |
| `[2:2]` | RW | REVOUT |
| `[1:1]` | RW | REVIN |
| `[0:0]` | RW | EN |

reset value: `0x0000_0000`

* SIZE: the size of input data
    * `2'b00`: 8 bits
    * `2'b01`: 16 bits
    * `2'b10`: 24 bits
    * `2'b11`: 32 bits

* MODE: the CRC polynomials mode
    * `2'b00`: CRC8 (poly: 0x07)
    * `2'b01`: CRC16 (poly: 0x1021)
    * `2'b10`: CRC16 (poly: 0x8005)
    * `2'b11`: CRC32 (poly: 0x04c11db7)

* REVOUT: bit reverse of CRC output value
    * `1'b0`: disable
    * `1'b1`: enable

* REVIN: byte reverse of CRC input value
    * `1'b0`: disable
    * `1'b1`: enable

* EN: the enable signal of CRC core
    * `1'b0`: disable
    * `1'b1`: enable

#### Init Value Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | INIT |

reset value: `0x0000_0000`

* INIT: the init value of CRC result

#### XOR Value Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | XORV |

reset value: `0x0000_0000`

* XORV: the xor value of CRC result

#### Data Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:0]` | RW | DATA |

reset value: `0x0000_0000`

* DATA: the input or result value of CRC
    * write this regiser will start a new CRC calculation
    * read this register will get CRC result

#### State Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:1]` | none | reserved |
| `[0:0]` | RO | DONE |

reset value: `0x0000_0000`

* DONE: the state of the CRC calculation
    * `1'b0`: no done
    * `1'b1`: done

### Program Guide
The software operation of `crc` is simple. These registers can be accessed by 4-byte aligned read and write. C-like pseudocode operation:
```c
// for example: CRC16-8005, REVOUT: true, REVIN: true, SIZE: 32
uint32_t val;
crc.CTRL = (uint32_t)0                             // disable the crc core
crc.INIT = INIT_32_bit                             // write the crc init value
crc.XORV = XORV_32_bit                             // write the xor value of crc result
crc.CTRL.[SIZE, MODE, EN] = [0b11, 0b10, 1, 1, 1]  // set the control mode of crc
crc.DATA = VAL_32_bit                              // write the value which need to be calculated
...
while(crc.STAT != DONE){}                          // wait the calculation is end

RES_VALUE = crc.DATA                               // read the result

```
complete driver and test codes in [driver](../driver/) dir.

### Resoureces
### References
### Revision History