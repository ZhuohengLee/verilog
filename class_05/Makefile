# List all module files
SRC = datapath.v if_stage.v pc.v instruction_memory.v \
      reg_file.v alu.v data_memory.v
TB  = datapath_tb.v

OUT = datapath.out
VCD = datapath.vcd

all: compile run

compile:
	iverilog -o $(OUT) $(TB) $(SRC)

run:
	vvp -n $(OUT)

wave:
	gtkwave $(VCD) &

clean:
	if exist $(OUT) del $(OUT)
	if exist $(VCD) del $(VCD)