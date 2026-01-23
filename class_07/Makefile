# Week 7: Pipeline Integration & Control Propagation
# Build system for the 5-stage MIPS pipeline
      alu.v reg_file.v data_memory.v instruction_memory.v pc.v

all: sim

sim:
	iverilog -o test.vvp $(SRC)
	vvp test.vvp

wave: sim
	gtkwave mips.vcd &

clean:
	rm -f *.vvp *.vcd *.out