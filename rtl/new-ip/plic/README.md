# PLIC

## Features
* Compatible with RISCV PLIC 1.0.0 standard
* One hart target support only
* Up to 31 external peripheral interrupt
* 16 interrupt prority levels support
* Rising edge and high level trigger types configuration
* Programmable pending counter to queue edge trigger interrupt requests
* Independent maskable and pending bit for every interrupt source
* Static synchronous design
* Full synthesizable

FULL vision of datatsheet can be found in [datasheet.md](./doc/datasheet.md).

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```