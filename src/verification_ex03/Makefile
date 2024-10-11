
ifndef VERILATOR_ROOT
$(error "No Verilator Root defined - please define a root dir")
endif

SRC:=counter.v
OBJ:=obj_dir/Vtb

.PHONY: sby

$(OBJ): $(SRC)
	$(VERILATOR_ROOT)/bin/verilator --build --cc $^

sby: counter.sby
	sby -f $^
