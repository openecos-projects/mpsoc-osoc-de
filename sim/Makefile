ROOT := $(abspath ..)
SHELL := /bin/bash
RTL_DIR := $(ROOT)/rtl
BUILD_DIR := $(ROOT)/build/verilator
GENERATED_DIR := $(ROOT)/build/generated
THREADS ?= 1
TRACE ?= 0
SIM_OUTPUT ?= 0
OBJ_DIR := $(BUILD_DIR)/obj_dir$(if $(filter 1,$(THREADS)),,_t$(THREADS))$(if $(filter 1,$(TRACE)),_trace,)$(if $(filter 1,$(SIM_OUTPUT)),_output,)
LOG_DIR := $(BUILD_DIR)/log
SIM_BIN := $(OBJ_DIR)/VSimTop

VERILATOR ?= $(if $(wildcard $(HOME)/oss-cad-suite/bin/verilator),$(HOME)/oss-cad-suite/bin/verilator,verilator)
BASE_IMAGE := $(ROOT)/prog/hello-minirv-ysyxsoc.bin
CPU_ID ?= 1
GENERATED_IMAGE := $(BUILD_DIR)/images/hello-minirv-ysyxsoc-cpu$(CPU_ID).bin
IMAGE ?= $(GENERATED_IMAGE)
CORE_SEL ?= $(CPU_ID)
RCU_EN ?= 1
MAX_CYCLES ?= 30000000
RESET_CYCLES ?= 20
PROGRESS_CYCLES ?= 1000000
WAVE ?= $(BUILD_DIR)/SimTop.fst
LOG ?= $(LOG_DIR)/hello-minirv-ysyxsoc-cpu$(CPU_ID)-rcu$(RCU_EN).log

HARNESS := $(CURDIR)/sim_main.cpp
CPUID_SCRIPT := $(ROOT)/prog/change-cpuid.sh
ASSEMBLE_SCRIPT := $(ROOT)/scripts/assemble-cores.py
USER_CORES ?= $(ROOT)/user-cores/cores.list
FAST_SPI_MODEL := $(CURDIR)/spi_top_apb_fast.sv
FAST_PSRAM_MODEL := $(CURDIR)/psram_wrapper_fast.sv
PSRAM_REPLACE_AWK := $(CURDIR)/replace_psram_wrapper.awk
ASSEMBLED_SOC := $(GENERATED_DIR)/asicTopYSYXstageDE_user.v
USER_FILELIST := $(GENERATED_DIR)/user-filelist.f
SIM_SOC := $(BUILD_DIR)/asicTopYSYXstageDE_sim.v
FILELIST_SOURCES := $(filter-out soc/asicTopYSYXstageDE.v perip/spi/rtl/spi_top_apb.v,$(shell sed -e '/^[[:space:]]*$$/d' $(RTL_DIR)/filelist.f))
RTL_SOURCES := $(shell find $(RTL_DIR) -path '*/.git' -prune -o -type f \( -name '*.v' -o -name '*.sv' -o -name '*.vh' -o -name '*.svh' \) -print)

VERILATOR_FLAGS := \
	--cc --exe --build --build-jobs 0 --timing --threads $(THREADS) \
	--top-module SimTop --Mdir $(OBJ_DIR) \
	--timescale-override 1ns/1ns \
	-O3 --x-assign fast --x-initial fast \
	-Wall -Wno-fatal \
	-Wno-DECLFILENAME -Wno-UNUSEDPARAM -Wno-UNUSEDSIGNAL \
	-Wno-BLKSEQ -Wno-SYNCASYNCNET -Wno-CASEINCOMPLETE \
	-MAKEFLAGS "OPT_FAST=-O3" \
	-CFLAGS "-std=c++17 -O3"

ifeq ($(TRACE),1)
VERILATOR_FLAGS += --trace-fst -CFLAGS "-DVM_TRACE=1"
RUN_TRACE_ARG := +trace=$(WAVE)
endif

ifeq ($(SIM_OUTPUT),1)
VERILATOR_FLAGS += -CFLAGS "-DYSYXSOC_SIM_OUTPUT=1"
endif

.PHONY: all check check-image image lint assemble verilate sim clean

all: sim

check:
	@test -x "$(VERILATOR)" || command -v "$(VERILATOR)" >/dev/null 2>&1 || \
		{ echo "ERROR: verilator not found: $(VERILATOR)"; exit 127; }
	@test "$(CPU_ID)" -ge 0 -a "$(CPU_ID)" -le 31 2>/dev/null || \
		{ echo "ERROR: CPU_ID must be in [0, 31]"; exit 2; }
	@python3 $(ASSEMBLE_SCRIPT) --root $(ROOT) --manifest $(USER_CORES) --cpu-id $(CPU_ID) --check-only

assemble: $(ASSEMBLED_SOC) $(USER_FILELIST)

$(ASSEMBLED_SOC) $(USER_FILELIST): $(ROOT)/rtl/soc/asicTopYSYXstageDE.v $(ROOT)/rtl/filelist.f $(ASSEMBLE_SCRIPT) $(USER_CORES)
	@python3 $(ASSEMBLE_SCRIPT) --root $(ROOT) --manifest $(USER_CORES)

check-image: $(if $(filter $(GENERATED_IMAGE),$(IMAGE)),$(GENERATED_IMAGE))
	@test -f "$(IMAGE)" || { echo "ERROR: image not found: $(IMAGE)"; exit 2; }

$(GENERATED_IMAGE): $(BASE_IMAGE) $(CPUID_SCRIPT)
	@mkdir -p $(dir $@)
	@cd $(ROOT)/prog && bash ./change-cpuid.sh $(CPU_ID) $@

image: check $(GENERATED_IMAGE)
	@echo $(GENERATED_IMAGE)

lint: check assemble $(SIM_SOC)
	@cd $(RTL_DIR) && $(VERILATOR) --lint-only --timing --top-module SimTop \
		--timescale-override 1ns/1ns -Wno-fatal $(SIM_SOC) -f $(USER_FILELIST) -f simflag.txt

$(SIM_SOC): $(ASSEMBLED_SOC) $(FAST_PSRAM_MODEL) $(PSRAM_REPLACE_AWK)
	@mkdir -p $(BUILD_DIR)
	@awk -v replacement=$(FAST_PSRAM_MODEL) -f $(PSRAM_REPLACE_AWK) $< > $@.tmp
	@mv $@.tmp $@

$(SIM_BIN): $(CURDIR)/Makefile $(HARNESS) $(FAST_SPI_MODEL) $(SIM_SOC) $(USER_FILELIST) $(RTL_DIR)/simflag.txt $(RTL_SOURCES)
	@mkdir -p $(OBJ_DIR) $(LOG_DIR)
	@cd $(RTL_DIR) && $(VERILATOR) $(VERILATOR_FLAGS) \
		$(SIM_SOC) -f $(USER_FILELIST) $(FAST_SPI_MODEL) -f simflag.txt $(HARNESS)

verilate: check $(SIM_BIN)

sim: verilate check-image
	@mkdir -p $(LOG_DIR)
	@set -o pipefail; $(SIM_BIN) \
		+image=$(IMAGE) +core-sel=$(CORE_SEL) +rcu-en=$(RCU_EN) \
		+max-cycles=$(MAX_CYCLES) +reset-cycles=$(RESET_CYCLES) \
		+progress-cycles=$(PROGRESS_CYCLES) \
		$(RUN_TRACE_ARG) 2>&1 | tee $(LOG)

clean:
	@rm -rf $(BUILD_DIR) $(GENERATED_DIR)
