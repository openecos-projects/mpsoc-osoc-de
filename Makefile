.DEFAULT_GOAL := help

CPU_ID ?= 0
USER_CORES ?= user-cores/cores.list

.PHONY: help check assemble lint image sim trace export-user-kit clean

help:
	@printf '%s\n' \
		'make check CPU_ID=N       validate the fixed image and core map' \
		'make assemble             generate the user-slot top and filelist' \
		'make lint                lint the assembled SoC and user cores' \
		'make image CPU_ID=N      patch the fixed hello image for slot N' \
		'make sim CPU_ID=N        run the MCU -> RCU -> selected core flow' \
		'make trace CPU_ID=N      run simulation with an FST waveform' \
		'make export-user-kit     create build/user-kit for publication' \
		'make clean               remove generated build products'

check:
	@python3 scripts/assemble-cores.py --root . --manifest $(USER_CORES) --check-only
	@$(MAKE) -C sim check CPU_ID=$(CPU_ID) USER_CORES=$(abspath $(USER_CORES))
	@$(MAKE) -C sim image CPU_ID=$(CPU_ID)

assemble:
	@python3 scripts/assemble-cores.py --root . --manifest $(USER_CORES)

lint: assemble
	@$(MAKE) -C sim lint CPU_ID=$(CPU_ID) USER_CORES=$(abspath $(USER_CORES))

image:
	@$(MAKE) -C sim image CPU_ID=$(CPU_ID)

sim:
	@$(MAKE) -C sim sim CPU_ID=$(CPU_ID) USER_CORES=$(abspath $(USER_CORES))

trace:
	@$(MAKE) -C sim sim CPU_ID=$(CPU_ID) TRACE=1 USER_CORES=$(abspath $(USER_CORES))

export-user-kit:
	@python3 scripts/export-user-kit.py --root . --output build/user-kit

clean:
	@rm -rf build
