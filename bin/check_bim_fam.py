#!/opt/conda/bin/python
from sys import argv


def check_bim(file):
    bad_lines = []
    for line in open(file).readlines():
        if len(line.split()) != 6:
            bad_lines.append(line)
    if bad_lines:
        return ", ".join(bad_lines)
    return "OK"

status_bim = check_bim(argv[1])
if status_bim != "OK":
    print(f"Mal-formed lines in {argv[2]} file: {status_bim}")
    exit(1)