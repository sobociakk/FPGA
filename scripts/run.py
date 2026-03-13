#!/usr/bin/env python3
import argparse
import subprocess
import sys
import logging
from pathlib import Path

# Configure professional logging standard
logging.basicConfig(
    level=logging.INFO,
    format="[%(levelname)s] %(asctime)s - %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)

class VerificationRunner:
    def __init__(self):
        # Dynamiczne odnajdywanie katalogu głównego projektu. 
        # Zakładamy, że skrypt leży w katalogu 'scripts' lub bezpośrednio w root.
        script_dir = Path(__file__).resolve().parent
        if script_dir.name == "scripts":
            self.project_root = script_dir.parent
        else:
            self.project_root = script_dir

        self.rtl_dir = self.project_root / "rtl"
        self.tb_dir = self.project_root / "tb"
        self.build_dir = self.project_root / "build"

        self.sim_executable = self.build_dir / "sim_output"
        self.wave_file = self.build_dir / "waves.vcd"

    def verify_environment(self):
        """Ensures the required directory structure exists."""
        required_dirs = [self.rtl_dir, self.tb_dir, self.build_dir]
        for directory in required_dirs:
            if not directory.exists():
                rel_path = directory.relative_to(self.project_root)
                logger.error(f"Missing required directory: {rel_path}")
                sys.exit(1)

    def run_cmd(self, cmd_list, ignore_error=False):
        """Executes a shell command safely using lists."""
        cmd_str = " ".join(str(c) for c in cmd_list)
        logger.info(f"Executing: {cmd_str}")
        
        process = subprocess.run(cmd_list, capture_output=True, text=True)

        if process.returncode != 0 and not ignore_error:
            logger.error(f"Command failed (code {process.returncode})")
            # Narzędzia EDA często wyrzucają błędy na STDOUT, więc logujemy oba
            if process.stdout.strip():
                logger.error(f"STDOUT:\n{process.stdout.strip()}")
            if process.stderr.strip():
                logger.error(f"STDERR:\n{process.stderr.strip()}")
            sys.exit(1)

        return process.stdout

    def lint_design(self):
        """Runs Verilator strictly as a linter on RTL files."""
        rtl_files = list(self.rtl_dir.glob("*.sv"))
        if not rtl_files:
            logger.warning("No RTL files found for linting.")
            return

        logger.info("Starting RTL linting phase with Verilator...")
        lint_cmd = ["verilator", "--lint-only", "-Wall", "-Wno-MULTITOP"] + rtl_files
        self.run_cmd(lint_cmd)
        logger.info("Linting successful. No RTL structural issues found.")

    def compile_design(self, tb_name):
        """Compiles all RTL files but ONLY the specified testbench."""
        rtl_files = list(self.rtl_dir.glob("*.sv"))
        
        # Zbuduj ścieżkę do konkretnego pliku testbench
        tb_file = self.tb_dir / f"{tb_name}.sv"
        
        if not tb_file.exists():
            logger.error(f"Testbench file not found: {tb_file}")
            sys.exit(1)

        all_src_files = rtl_files + [tb_file]

        if not rtl_files:
            logger.warning("No .sv files found in 'rtl' directory. Compiling TB only.")

        logger.info(f"Starting compilation phase for {tb_name}...")
        
        # Opcjonalnie: możemy nazwać plik wyjściowy od nazwy testbenchu, np. build/tb_uart_tx.vvp
        self.sim_executable = self.build_dir / f"{tb_name}.vvp"
        
        compile_cmd = ["iverilog", "-g2012", "-o", self.sim_executable] + all_src_files
        self.run_cmd(compile_cmd)
        logger.info("Compilation successful.")

    def run_simulation(self, tb_name, seed=None):
        logger.info("Starting simulation phase...")
        # Używamy zaktualizowanej nazwy pliku wykonywalnego
        sim_cmd = ["vvp", self.build_dir / f"{tb_name}.vvp"]

        if seed is not None:
            sim_cmd.append(f"+SEED={seed}")
            logger.info(f"Using random seed: {seed}")

        output = self.run_cmd(sim_cmd)
        self._parse_results(output)

    def _parse_results(self, sim_output):
        """Parses the simulation output to determine Pass/Fail status."""
        logger.info("Parsing simulation logs...")

        print("\n--- SIMULATION OUTPUT ---")
        print(sim_output.strip())
        print("-------------------------\n")

        if "Simulation completed successfully!" in sim_output:
            logger.info("STATUS: PASSED \U0001F7E2")
        else:
            logger.error("STATUS: FAILED \U0001F534")

    def open_waves(self):
        """Opens GTKWave in a non-blocking background process."""
        if not self.wave_file.exists():
            logger.warning(
                f"Waveform not found at {self.wave_file.relative_to(self.project_root)}. "
                "Did you run the simulation?"
            )
            return

        logger.info(f"Launching GTKWave with {self.wave_file.name}...")
        subprocess.Popen(
            ["gtkwave", self.wave_file],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

def main():
    parser = argparse.ArgumentParser(
        description="Professional ASIC/FPGA Verification Runner"
    )
    parser.add_argument("action", choices=["run", "wave"], help="Action to perform")
    # NOWY ARGUMENT:
    parser.add_argument("tb_name", help="Name of the testbench to run (without .sv extension)")
    
    parser.add_argument(
        "--seed",
        type=int,
        help="Random seed for simulation (for reproducible tests)",
    )

    args = parser.parse_args()
    runner = VerificationRunner()
    runner.verify_environment()

    if args.action == "run":
        runner.lint_design() 
        runner.compile_design(args.tb_name)
        runner.run_simulation(args.tb_name, seed=args.seed)
    elif args.action == "wave":
        runner.open_waves()

if __name__ == "__main__":
    main()