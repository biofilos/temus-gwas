# TEMUS Technical interview challenge

This repository contains the code produced as part of the [coding challenge](https://www.kaggle.com/datasets/103b608eea3a94c5c98260738d80039c5573eb7f80dc0a8e4f865cb90fbc6ea4?resource=download) to apply for the position of Data Engineer (Genomics) at Temus. The challenge consists of building a Nextflow pipeline to run a GWAS analysis. 

## Dataset
The dataset used in this challenge consists of plink-formatted genotype data (.bed, .bim, .fam), a phenofile, and a sample file with information of the ethnic groups of the samples.

## Software requirements
In order to run the pipeline, the following software is required
- Nextflow version 24.04.3
- Docker
- Python version 3.12
- awscli version 2 (if running on AWS)

## Input
The pipeline was designed to be executed using AWS cloud infrastructure, or in a local machine. To ease its execution, all necessary parameters have been specified in `nextflow.config`, and parameters specific for the relevant computing environments are coded in the files `conf/local.config` and `conf/aws.config`. Users can also specify the parameters of the pipeline using the command line if considered necessary for different applications.  
The following are the mandatory parameters that the pipeline accepts via command line (e.g. `nextflow run --parameter1 value 1`). These parameters specify the input data that the pipeline expects to run:
- bed: Plink binary genotype file
- bim: Plink variant information file
- fam: Plink sample information file
- pheno: Phenofile (format information [here](https://rgcgithub.github.io/regenie/options/#phenotype-file-format))
- samples: Tab-delimited file with two columns
  - FID: family ID
  - ETHNIC_GROUP: Ethnic group

The following parameters are optional (default values are presented in [square brackets])
- var_missing [0.01]: Variant missingness fraction
- sample_missing [0.01]: Sample missingess fraction
- maf [0.05]: Minor allele frequency threshold
- hwe [1e-15]: Herdy-Weimberg equilibrium P-value threshold. (Set to 1 to deactivate)
- min_vars [100]: Minimum number of variants per chromosome

This pipeline can be conveniently executed with default parameters and input files, by using one of the following profiles
- local: Runs the pipeline in the current computer
- aws: Runs the pipeline in AWS (credentials necessary to use this profile available if requested)

In order to run the pipeline locally, execute the command: `nextflow run -profile local .`. This command will automatically download and stage the input files, and execute the pipeline.  
To run the pipeline using AWS cloud resources, execute the command: `nextflow run -profile aws -bucket-dir s3://temus-interview-data-jfo/gwas/temus/output` This command will use AWS resources (see below) to run the pipeline, and will show the location of the results of the pipeline. Users can download the results by using the awscli command.

## AWS Setup
In order to showcase how to use cloud infrastructure to efficiently run Nextflow pipelines, I built and configured all the AWS resources needed. If 