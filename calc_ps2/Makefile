# ==========================================
# Verification Makefile (Vivado XSIM)
# ==========================================

# --- Toolchain definition ---
XVLOG   = xvlog
XELAB   = xelab
XSIM    = xsim
LINTER  = verilator
PYTHON  = python3

# --- Project configuration ---
# Select 'system' for tb_system.f or 'unit' for tb_unit.f
TEST_TYPE ?= system
TB_TOP    ?= tb_top
RTL_TOP   ?= fpga_top

# --- Directories ---
FILELIST_DIR = filelists
SIM_DIR      = sim
SIM_OUT      = $(SIM_DIR)/out

# Organized subdirectories for simulation output
SIM_LOGS  = $(SIM_OUT)/logs
SIM_SNAPS = $(SIM_OUT)/snaps
SIM_WAVES = $(SIM_OUT)/waves

# --- Filelists ---
RTL_FILELIST = $(FILELIST_DIR)/rtl.f
TB_FILELIST  = $(FILELIST_DIR)/tb_$(TEST_TYPE).f

# --- Tool flags ---
LINT_FLAGS = --lint-only -Wall -sv --top-module $(RTL_TOP)

# Progress markers
LINT_MARKER    = $(SIM_OUT)/.lint.done
COMPILE_MARKER = $(SIM_OUT)/.compile.done
ELAB_MARKER    = $(SIM_OUT)/.elab.done

.PHONY: all lint compile elaborate sim wave clean setup

# Lint is removed from 'all' so it only runs on demand via 'make lint'
all: sim

# --- 0. Directory Setup ---
setup:
	@mkdir -p $(SIM_LOGS)
	@mkdir -p $(SIM_WAVES)

# --- 1. Linting (Static Analysis) ---
lint: $(LINT_MARKER)

$(LINT_MARKER): | setup
	@echo "=== 1. Linting module: $(RTL_TOP) ==="
	$(LINTER) $(LINT_FLAGS) -f $(RTL_FILELIST)
	@touch $@

# --- 2. Compilation (xvlog) ---
compile: $(COMPILE_MARKER)

$(COMPILE_MARKER): | setup
	@echo "=== 2. Compiling test type: $(TEST_TYPE) ==="
	$(XVLOG) -sv -f $(TB_FILELIST) -log $(SIM_LOGS)/xvlog.log
	@touch $@

# --- 3. Elaboration (xelab) ---
elaborate: $(ELAB_MARKER)

$(ELAB_MARKER): compile
	@echo "=== 3. Elaborating top: $(TB_TOP) ==="
	$(XELAB) -debug typical -top $(TB_TOP) -snapshot $(TB_TOP)_snap -log $(SIM_LOGS)/xelab.log
	@touch $@

# --- 4. Simulation (xsim) ---
sim: elaborate
	@echo "=== 4. Running Simulation ==="
	@echo "log_wave -recursive *; run all; exit" > $(SIM_WAVES)/xsim_cfg.tcl
	$(XSIM) $(TB_TOP)_snap -tclbatch $(SIM_WAVES)/xsim_cfg.tcl -wdb $(SIM_WAVES)/$(TB_TOP)_wave.wdb -log $(SIM_LOGS)/xsim_run.log | tee $(SIM_LOGS)/$(TB_TOP)_sim_stdout.log
	@echo "=== Analyzing log ==="
	@$(PYTHON) scripts/check_sim.py $(SIM_LOGS)/$(TB_TOP)_sim_stdout.log || true

# --- 5. Waveform Viewing ---
wave:
	@echo "=== Opening Vivado XSIM GUI ==="
	# Open the generated waveform file
	$(XSIM) $(SIM_WAVES)/$(TB_TOP)_wave.wdb -gui

# --- 6. Cleanup ---
clean:
	@echo "=== Cleaning Workspace ==="
	rm -rf $(SIM_OUT)
	rm -rf syn/out/*
	rm -rf xsim.dir .Xil
	rm -f *.jou *.log *.pb *.wdb

.PHONY: synth

synth:
	@echo "=== Starting Synthesis ==="
	@mkdir -p syn/out
	vivado -mode batch -source scripts/synth.tcl -log syn/out/vivado_synth.log