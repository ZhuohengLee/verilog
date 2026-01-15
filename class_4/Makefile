# Note: We must compile 3 source files here
SRC = if_stage.v pc.v instruction_memory.v
TB  = if_stage_tb.v

OUT = if_stage.out
VCD = if_stage.vcd

# Default Target
all: compile run

# Compile Target
compile:
	iverilog -o $(OUT) $(TB) $(SRC)

# Run Simulation Target
run:
	vvp -n $(OUT)

# View Waveforms Target
wave:
	gtkwave $(VCD) &

# Clean Target (Windows compatible)
clean:
	if exist $(OUT) del $(OUT)
	if exist $(VCD) del $(VCD)