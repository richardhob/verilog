
SRC_V:=shift.v
SRC_C:=tb.cpp

OBJ:=obj_dir/Vshift

.PHONY: run

$(OBJ): $(SRC_C) $(SRC_V)
	verilator --build -Wall --trace --cc --exe $^

run: $(OBJ)
	$(OBJ)
