## Datasheet

### Overview
The `archinfo` IP is a fully parameterised soft IP recording the SoC architecture and ASIC backend informations. The IP features an APB4 slave interface, fully compliant with the AMBA APB Protocol Specification v2.0. For testing purposes, the registers of `archinfo` are writable. But in production environment, these registers are read-only. 

### Feature
* 32-bit read-only system architecture register
* 64-bit read-only id architecture register
* Static synchronous design
* Full synthesizable

### Interface
| port name | type        | description          |
|:--------- |:------------|:---------------------|
| apb4      | interface   | apb4 slave interface |

### Register

| name | offset  | length | description |
|:----:|:-------:|:-----: | :---------: |
| [SYS](#system-info-register) | 0x0 | 4 | system info register |
| [IDL](#id-low-reigster) | 0x4 | 4 | id low register |
| [IDH](#id-high-reigster) | 0x8 | 4 | id high register |

#### System Info Register
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:20]` | none | reserved |
| `[19:8]` | RW | CLOCK |
| `[7:0]` | RW | SRAM |

reset value: `depend on specific shuttle`

* CLOCK: core clock frequency information by using three-bit BCD code
* SRAM: the total size of SRAM, unit: KB. example: `SRAM=128` means 128KB

#### ID Low Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:30]` | RW | TYPE |
| `[29:22]` | RW | VENDOR |
| `[21:6]` | RW | PROCESS |
| `[5:0]` | RW | CUST |

reset value: `depend on specific shuttle`

* TYPE: tape out type 
    * `2'b00`: OSOC (one student one chip)
    * `2'b01`: IEDA (open source eda)
    * `2'b10`: EP (epiboly)
    * `2'b11`: TEST (prototype test)
* VENDOR: asic vendor encoding, the encoding table is currently not publicly open available
* PROCESS: the process of tape out by using 4-bit BCD code, for example, the `0130` means the 130nm process
* CUST: user customized information

#### ID High Reigster
| bit | access  | description |
|:---:|:-------:| :---------: |
| `[31:24]` | none | reserved |
| `[23:0]` | RW | DATE |

reset value: `depend on specific shuttle`

* DATE: the date of tape out by using six-bit BCD code, for example: 202404

### Program Guide
The software operation of `archinfo` is simple. These registers can be accessed by 4-byte aligned read and write. C-like pseudocode read operation:
```c
uint32_t val;
val = archinfo.SYS // read the sys register
val = archinfo.IDL // read the idl register
val = archinfo.IDH // read the idh register

```
write operation:
```c
uint32_t val = value_to_be_written;
archinfo.SYS = val // write the sys register
archinfo.IDL = val // write the idl register
archinfo.IDH = val // write the idh register

```
complete driver and test codes in [driver](../driver/) dir. 

### Resoureces
### References
### Revision History