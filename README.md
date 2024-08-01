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
To run the pipeline using AWS cloud resources, execute the command: `nextflow run -profile aws -bucket-dir s3://temus-interview-data-jfo/gwas/temus/output .` This command will use AWS resources (see below) to run the pipeline, and will show the location of the results of the pipeline. Users can download the results by using the awscli command.

## AWS Setup
In order to showcase how to use cloud infrastructure to efficiently run Nextflow pipelines, I built and configured all the AWS resources needed. If necessary, I will be glad to share the credentials needed to run the pipeline using AWS.  
Building the AWS architecture can be divided in 3 areas
1. IAM roles. This is to make sure that IAM roles and users are created with the minimum number of permissions necessary to run jobs.
2. Computing resources. Setting up an AMI with all the resources that it needs to orchestrate jobs
3. Batch. Batch queues and computing environment have to be created to allow Nextflow to distribute jobs in the queue

## Usage
1. Run `nextflow run -profile local .` or `nextflow run -profile aws -bucket-dir s3://temus-interview-data-jfo/gwas/temus/output` depending if the pipeline needs to be executed locally or in AWS.
2. Uncompress (or download and uncompress if using AWS) the results. The location of the results should appear at the end of the pipeline execution. Uncompress with `tar xf results.tar.gz`
3. Install `view-manhattan`. This is an application I developed for this Temus interview. It allows to interactively visualise Regenie output data, and explore its results. Install with `pip install regenie_viewer/dist/view_manhattan-0.1.0-py3-none-any.whl`
4. Run `view-manhattan results/regenie/`, where `results/regenie` is the location of the regenie files. The directory of the regenie files will be created when uncompressing `results.tar.gz`
5. Open a web browser at [127.0.0.1:8050](http://127.0.0.1:8050) to see the interactive report.

## Containers
Following best-practices, this pipeline uses Docker to run all its jobs. For this small pipeline, it is using only one container, but that can be modified. Given that the pipeline can run in two environments (local and AWS), two container registries have been setup (dockerhub, and AWS ECR). It is possible to run the pipeline in AWS using dockerhub containers. However, I want to showcase how to run it from ECR, as it is more performant, and allows us to run pipeline with private containers without the need to handle more credentials (e.g. Dockerhub).