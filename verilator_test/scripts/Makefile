TOP = counter

RTL_DIR = ../rtl
TB_DIR = ../tb
BUILD_DIR = ../build

SV_SRCS = $(wildcard $(RTL_DIR)/*.sv)
CPP_SRCS = $(wildcard $(TB_DIR)/*.cpp)

VERILATOR = verilator
GTKWAVE = gtkwave

.PHONY: all build run wave clean

all: wave

build:
	@echo "--- Building project ---"
	mkdir -p $(BUILD_DIR)
	$(VERILATOR) -Wall --trace --cc --exe --build $(SV_SRCS) $(CPP_SRCS) --top-module $(TOP) --Mdir $(BUILD_DIR)/obj_dir

run: build
	@echo "--- Running simulation ---"
	cd $(BUILD_DIR) && ./obj_dir/V$(TOP)

wave: run
	@echo "--- Opening GTKWave ---"
	cd $(BUILD_DIR) && $(GTKWAVE) waveform.vcd &

clean:
	@echo "--- Cleaning up ---"
	rm -rf $(BUILD_DIR)/*
