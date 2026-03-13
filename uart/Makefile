# ==========================================
# Professional Verification Makefile (Vivado XSIM)
# ==========================================

# Narzędzia Xilinx Vivado (muszą być dodane do zmiennej PATH)
XVLOG = xvlog
XELAB = xelab
XSIM  = xsim

# Pozostałe narzędzia
WAVES  = gtkwave
LINTER = verilator
PYTHON = python3

# Flagi dla Verilatora (Linting)
LINT_FLAGS = --lint-only -Wall -sv --top-module $(RTL_TOP)

# Konfiguracja Modułów (nadpisywalna)
RTL_TOP ?= rtl_top
TB_NAME ?= tb_name

# Katalogi i pliki
TB_DIR = tb
BUILD_DIR = build
FILELIST = $(TB_DIR)/$(TB_NAME).f
SIM_LOG = $(BUILD_DIR)/$(TB_NAME)_sim.log

# Wyciąganie plików RTL do Lintingu
RTL_ONLY = $(shell grep -E '^(rtl|src|hdl)/' $(FILELIST))

# ==========================================
# Targets
# ==========================================
.PHONY: all lint compile elaborate sim wave clean setup

all: setup lint sim

setup:
	@mkdir -p $(BUILD_DIR)

lint:
	@echo "=== 1. Linting TOP module: $(RTL_TOP) ==="
	$(LINTER) $(LINT_FLAGS) $(RTL_ONLY)

compile: setup
	@echo "=== 2. Compiling (xvlog) for: $(TB_NAME) ==="
	# xvlog używa flagi -sv dla SystemVeriloga i -f dla list plików
	$(XVLOG) -sv -f $(FILELIST)

elaborate: compile
	@echo "=== 3. Elaborating (xelab) for: $(TB_NAME) ==="
	# xelab tworzy obraz symulacji (snapshot). -debug typical pozwala na zrzut fal.
	$(XELAB) -debug typical -top $(TB_NAME) -snapshot $(TB_NAME)_snap

sim: elaborate
	@echo "=== 4. Running Simulation (xsim) ==="
	# -R uruchamia symulację do końca (run all)
	$(XSIM) $(TB_NAME)_snap -R | tee $(SIM_LOG)
	@echo "=== Analyzing Simulation Log ==="
	@$(PYTHON) scripts/check_sim.py $(SIM_LOG)

wave:
	@echo "=== Opening GTKWave ==="
	# Zakłada, że w testbenchu używasz $dumpfile("waves.vcd");
	$(WAVES) waves.vcd > /dev/null 2>&1 &

clean:
	@echo "=== Cleaning Workspace ==="
	rm -rf $(BUILD_DIR)
	rm -rf xsim.dir .Xil
	rm -f *.jou *.log *.pb *.vcd *.wdb