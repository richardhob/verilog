

VERILATOR_ROOT=/data/data/com.termux/files/home/verilator

SRC:=tb.v thruwire.v
OBJ:=obj_dir/Vtb

.PHONY: run

$(OBJ): $(SRC)
	$(VERILATOR_ROOT)/bin/verilator --build --cc --exe $^ --top-module tb --timing --binary

run: $(OBJ)
	$(OBJ)
