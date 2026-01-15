# 1. Define file name variables
SRC = instruction_memory.v
TB  = instruction_memory_tb.v

# Define output file names
OUT = imem_wave.out
# Note: The VCD name must match $dumpfile("instr_mem.vcd") in the testbench
VCD = instr_mem.vcd

# 2. Default Target
all: compile run

# 3. Compile Target
compile:
	iverilog -o $(OUT) $(TB) $(SRC)

# 4. Run Simulation Target
run:
	vvp -n $(OUT)

# 5. View Waveforms Target
wave:
	gtkwave $(VCD) &

# 6. Clean Target (Windows compatible)
clean:
	if exist $(OUT) del $(OUT)
	if exist $(VCD) del $(VCD)