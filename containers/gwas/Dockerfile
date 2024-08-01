FROM condaforge/mambaforge:4.12.0-0
LABEL ecr="010526263385.dkr.ecr.ap-southeast-1.amazonaws.com/gwas"
LABEL docker-repo="juanfortizq/gwas"

RUN mamba install -c conda-forge -c bioconda -y \
    regenie plink2 seaborn pandas plotly dash-bio