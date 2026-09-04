# RNG

## Features
* Internal 32-bit LSFR implemented with max sequence
* 32-bit programmable seed register
* Generate one random number per cycle
* Static synchronous design
* Full synthesizable

FULL vision of datatsheet can be found in [datasheet.md](./doc/datasheet.md).

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```