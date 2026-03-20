import sys
import os
import subprocess
import re

program = sys.argv[1]
directory = sys.argv[2]

if not os.path.isdir(directory):
    print(f"Error: Directory '{directory}' does not exist.")
    sys.exit(1)

has_error = False

for filename in os.listdir(directory):
    filepath = os.path.join(directory, filename)
    if os.path.isfile(filepath):
        print(f"Running {program} on {filepath}")
        try:
            result = subprocess.run([program, filepath], capture_output=True, text=True)
        except Exception as e:
            print(f"Error: Failed to run {program} on {filepath}: {e}")
            has_error = True
            continue

        match = re.search(r"Exiting with code (\d+)", result.stdout)
        if match:
            exit_code = int(match.group(1))
            if exit_code != 0:
                print(f"Error: {program} reported exit code {exit_code} for file {filepath}")
                print(f"stdout: {result.stdout}")
                has_error = True
        else:
            print(f"Error: Could not find exit code in output for file {filepath}")
            has_error = True

if has_error:
    print("Errors detected during execution.")
    sys.exit(1)
else:
    print("All files processed successfully.")
    sys.exit(0)
