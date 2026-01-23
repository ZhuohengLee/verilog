all: sim

sim:
	iverilog -o test.vvp alu.v alu_tb.v
	vvp test.vvp

wave:
	gtkwave alu.vcd

clean:
	rm -f *.vvp *.vcd
