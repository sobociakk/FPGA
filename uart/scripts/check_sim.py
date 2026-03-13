import sys
import re
import os

# Require log file path as a command-line argument for CI/CD flexibility
if len(sys.argv) < 2:
    print("Error: Please provide the path to the simulation log file.")
    sys.exit(1)

log_file = sys.argv[1]

if not os.path.exists(log_file):
    print(f"Error: Log file not found at {log_file}")
    sys.exit(1)

errors = 0
warnings = 0

print(f"\n--- Simulation Log Analysis: {os.path.basename(log_file)} ---")

with open(log_file, "r") as f:
    for line in f:
        # \b ensures we match whole words (e.g., prevents matching 'fail_flag' variable)
        if re.search(r'\b(error|fail|fatal)\b', line, re.IGNORECASE):
            errors += 1
            print(f"[ERROR] {line.strip()}")
        elif re.search(r'\bwarning\b', line, re.IGNORECASE):
            warnings += 1

print("-" * 45)
if errors == 0:
    print(f"[SUCCESS] Simulation passed with {warnings} warnings.\n")
    sys.exit(0) # Returns 0 to Makefile, indicating success
else:
    print(f"[FAILURE] Simulation failed with {errors} errors.\n")
    sys.exit(1) # Returns 1 to Makefile, halting the build process