# CRC

## Features
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

FULL vision of datatsheet can be found in [datasheet.md](./doc/datasheet.md).

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```