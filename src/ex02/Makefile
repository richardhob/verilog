
SRC_V:=maskbus.v
SRC_C:=tb.cpp

OBJ:=obj_dir/Vmaskbus

.PHONY: run

$(OBJ): $(SRC_C) $(SRC_V)
	verilator --build -Wall --cc --exe $^

run: $(OBJ)
	$(OBJ)
