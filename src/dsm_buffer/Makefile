

OSS_CAD_SUITE:=~/oss-cad-suite/bin
VERILATOR:=$(OSS_CAD_SUITE)/verilator
SBY:=$(OSS_CAD_SUITE)/sby

SRC:=dsm_model.v tb.v
OBJ:=obj_dir/Vtb

.PHONY: all

all: run

$(OBJ): $(SRC)
	$(VERILATOR) --build --cc --exe $^ --top-module tb --timing --binary +define+TB=true

.PHONY: run
run: $(OBJ)
	$(OBJ)

.PHONY: check
check: $(SRC) yosis.sby
	$(SBY) -f yosis.sby
