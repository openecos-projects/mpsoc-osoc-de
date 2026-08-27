# PS2

## Features
* Support PS/2 keyboard only
* Configurable receive fifo depth
* Maskable fifo no-empty interrupt
* Static synchronous design
* Full synthesizable

FULL vision of datatsheet can be found in [datasheet.md](./doc/datasheet.md).

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```