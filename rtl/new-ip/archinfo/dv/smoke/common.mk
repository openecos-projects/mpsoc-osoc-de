NOVAS        := /nfs/tools/synopsys/verdi/V-2023.12-SP1-1/share/PLI/VCS/LINUX64
EXTRA        := -P ${NOVAS}/novas.tab ${NOVAS}/pli.a

SIM_TOOL     := bsub -Is vcs
SIM_BINY     := bsub -Is ./simv
VERDI_TOOL   := bsub -Is verdi
SIM_OPTIONS  := -full64 +v2k -sverilog -timescale=1ns/10ps \
                ${EXTRA} \
                -kdb \
                -debug_access+all \
                -debug_region=cell+lib \
                +error+500 \
                +vcs+flush+all \
                +lint=TFIPC-L \
                -xprop=../xprop.config \
                -work DEFAULT \
                +define+SV_ASSRT_DISABLE \

TIME_OPTION := +notimingcheck \
               +nospecify \

# spi solo repo root path
ROOT_PATH := ../../..

SIM_INC ?=
SIM_INC += +incdir+${ROOT_PATH}/rtl/
SIM_INC += +incdir+${ROOT_PATH}/../common/rtl
SIM_INC += +incdir+${ROOT_PATH}/../common/rtl/interface