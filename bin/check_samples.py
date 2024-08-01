#!/opt/conda/bin/python

from sys import argv

def check_samples(file):
    for ix, line in enumerate(open(file)):
        if ix == 0:
            if line != "FID\tETHNIC_GROUP\n":
                print('First line is not formatted correctly')
                exit(1)
        if len(line.strip().split('\t')) != 2:
            print('Line {} is not formatted correctly'.format(ix))
            exit(1)
    return 'OK'

status_samples = check_samples(argv[1])
print(status_samples)