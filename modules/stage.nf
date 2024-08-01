process stage {
  input:
    val input_url
  output:
    path "100000_variants_10000_samples_5_chromosomes.bed", emit: bed
    path "100000_variants_10000_samples_5_chromosomes.bim", emit: bim
    path "100000_variants_10000_samples_5_chromosomes.fam", emit: fam
    path "phenotype_10000_samples_100cols.txt", emit: pheno
    path "rsids_100000_variants_5_chromosomes.tsv", emit: rsids // not used in the pipeline
    path "samples.txt", emit: samples

  script:
  """
    wget -O input_data.tar.gz '${input_url}'
    tar -xvf input_data.tar.gz
  """
}