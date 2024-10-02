

VERILATOR_ROOT=/data/data/com.termux/files/home/verilator

SRC_V:=thruwire.v
SRC_C:=thruwire.cpp 

OBJ:=obj_dir/Vthruwire

.PHONY: run

$(OBJ): $(SRC_C) $(SRC_V)
	$(VERILATOR_ROOT)/bin/verilator --build -Wall --cc --exe $^ 

run: $(OBK)
	$(OBJ)
