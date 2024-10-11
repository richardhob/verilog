
ifndef VERILATOR_ROOT
$(error "No Verilator Root defined - please define a root dir")
endif

SRC:=double_pipe.v linear_feedback_shift.v
OBJ:=obj_dir/Vdouble_pipe

.PHONY: sby

$(OBJ): $(SRC)
	$(VERILATOR_ROOT)/bin/verilator --build --cc $^

sby: double_pipe.sby
	sby -f $^
