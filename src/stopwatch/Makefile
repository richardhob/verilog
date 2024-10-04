
SRC_V:=stopwatch.v
SRC_C:=tb.cpp
OBJ:=obj_dir/Vstopwatch

.PHONY: run clean

$(OBJ): $(SRC_C) $(SRC_V)
	verilator --build -Wall --trace --cc --exe $^

run: $(OBJ)
	$(OBJ)

clean:
	rm $(OBJ)
