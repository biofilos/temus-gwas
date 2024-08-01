#!/opt/conda/bin/python

from sys import argv

def check_phe(file):
    bad_lines = []
    n_cols = 0
    for ix, line in enumerate(open(file).readlines()):
        if ix == 0:
            if not line.startswith("FID IID"):
                print(f"Header in {file} is not FID IID")
                exit(1)
            n_cols = len(line.split())
        if len(line.split()) != n_cols:
            bad_lines.append(line)
    if bad_lines:
        print(", ".join(bad_lines))
        exit(1)
    return "OK"

status_phe = check_phe(argv[1])
print(status_phe)