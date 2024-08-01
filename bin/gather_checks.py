#!/opt/conda/bin/python
from sys import argv
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Read the sample and variant missingness files
basename = argv[1]
sample_missing = pd.read_csv(argv[2], sep='\t')
variant_missing = pd.read_csv(argv[3], sep='\t')
maf = pd.read_csv(argv[4], sep='\t')

# Plot the missingness
if sample_missing["F_MISS"].unique().size > 1:
    sns.histplot(sample_missing["F_MISS"], kde=True)
    plt.title(f"Sample missingness for population {basename}")
    plt.xlabel("Missingness")
    plt.ylabel("Frequency")
    plt.savefig(f"{basename}_sample_missingness.svg")
    plt.close()

if variant_missing["F_MISS"].unique().size > 1:
    sns.histplot(variant_missing["F_MISS"], kde=True)
    plt.title(f"Variant missingness for population {basename}")
    plt.xlabel("Missingness")
    plt.ylabel("Frequency")
    plt.savefig(f"{basename}_variant_missingness.svg")
    plt.close()

# Plot the MAF
if maf["ALT_FREQS"].unique().size > 1:
    sns.histplot(maf["ALT_FREQS"], kde=True)
    plt.title(f"Minor Allele Frequency for population {basename}")
    plt.xlabel("MAF")
    plt.ylabel("Frequency")
    plt.savefig(f"{basename}_maf.svg")
    plt.close()
