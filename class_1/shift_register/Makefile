# 1. Define file name variables (Modify these to match your filenames)
SRC = shift_register.v
TB  = shift_register_tb.v

# Define output file names
OUT = wave.out
VCD = shift_register.vcd

# 2. Default Target (The action performed when just typing 'make')
# This will automatically compile and run the simulation.
all: compile run

# 3. Compile Target
# Syntax: iverilog -o output_file testbench_file source_files
compile:
	iverilog -o $(OUT) $(TB) $(SRC)

# 4. Run Simulation Target
# Syntax: vvp -n executable_file
# The -n flag ensures the simulation exits automatically after finishing
# without entering interactive mode.
run:
	vvp -n $(OUT)

# 5. View Waveforms Target
# Syntax: gtkwave waveform_file
# The & symbol runs GTKWave in the background (preventing it from blocking the terminal).
wave:
	gtkwave $(VCD) &

# 6. Clean Target
# Deletes generated temporary files to keep the directory clean.
# Note: The commands below are specific to Windows (using 'del' instead of 'rm').
clean:
	if exist $(OUT) del $(OUT)
	if exist $(VCD) del $(VCD)