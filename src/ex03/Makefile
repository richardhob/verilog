
SRC_V:=blinky.v
SRC_C:=tb.cpp
OBJ:=obj_dir/Vblinky

.PHONY: run clean

$(OBJ): $(SRC_C) $(SRC_V)
	verilator --build -Wall --trace --cc --exe -GTHRESHOLD=5 $^

run: $(OBJ)
	$(OBJ)

clean:
	rm $(OBJ)
