# PWM

## Features
* 4 channels output compare with edge aligned
* Programmable prescaler
    * max division factor is up to 2^16
    * can be changed ongoing
* 16-bit programmable count up timer counter and compare register
* Auto reload counter
* Maskable overflow interrupt
* Static synchronous design
* Full synthesizable

FULL vision of datatsheet can be found in [datasheet.md](./doc/datasheet.md).

## Build and Test
```bash
make comp    # compile code with vcs
make run     # compile and run test with vcs
make wave    # open fsdb format waveform with verdi
```