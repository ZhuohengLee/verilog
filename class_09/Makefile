SRC = mips.v control_unit.v forwarding_unit.v \
      main_decoder.v alu_decoder.v \
      datapath.v pc.v instruction_memory.v \
      reg_file.v alu.v data_memory.v
TB  = mips_tb.v
OUT = forwarding.out
VCD = forwarding.vcd

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