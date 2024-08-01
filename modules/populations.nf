process split_samples {
  input:
    path(samples)
  output:
    path("*.samples")
  script:
  """
    for population in \$(grep -v ETHNIC_GROUP ${samples} | cut -f 2 | sort | uniq)
    do
        grep -P "\t\${population}" ${samples} > \${population}.samples
    done
  """
}

process split_populations {
    input:
        path(samples)
        tuple path(bed), path(bim), path(fam), path(pheno)
    output:
        tuple val("${samples.baseName}"), path("${samples.baseName}.bed"), path("${samples.baseName}.bim"), path("${samples.baseName}.fam"), path(pheno)
    script:
    """
        plink2 --bfile ${bed.baseName} --keep-fam ${samples} --pheno ${pheno} --make-bed --out ${samples.baseName}
    """

}

workflow BY_POPULATION {
  take:
    samples
    plink_in
  main:
  // takes the samples file and splits it into separate files for each population
  split_samples(samples).flatten().set{ch_samples}
  // takes the plink input files and splits them into separate files for each population
  split_populations(ch_samples, plink_in)
  emit:
    split_populations.out  
}