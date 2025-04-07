XRUN = xrun
XMELAB = xmelab
XMSIM = xmsim

SV_FILES = arbiter.sv controller.sv fifo.sv memory.sv mic.sv mic_pkg.sv mic_top.sv mux.sv register.sv mic_dut.sv tb_mic_reg.sv

# Compilation flags
COMP_FLAGS = -sv -64bit -access +rwc 

# Elaboration flags
ELAB_FLAGS = -access +rwc 

# Simulation flags
SIM_FLAGS = -64bit

# Default target
all: compile elaborate simulate

# Compile target
compile:
	@echo "Compiling SystemVerilog files..."
	$(XRUN) $(COMP_FLAGS) -compile -l compile.log $(SV_FILES)

# Elaborate target
elaborate:
	@echo "Elaborating design..."
	$(XMELAB) $(ELAB_FLAGS) tb_mic_reg

# Simulate target
simulate:
	@echo "Running simulation..."
	$(XMSIM) $(SIM_FLAGS) tb_mic_reg

# Clean up generated files
clean:
	rm -rf simv* csrc ucli.key *.vpd *.log *.daidir
