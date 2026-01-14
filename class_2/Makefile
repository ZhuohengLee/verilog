# 1. Define file name variables
SRC = alu.v
TB  = alu_tb.v

# Define output file names
OUT = wave.out
VCD = alu.vcd

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