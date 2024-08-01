process get_chromosomes {
    input:
        path(bim)
    output:
        path("chromosomes.txt")
    script:
        """
        cut -f 1 ${bim} | sort | uniq > chromosomes.txt
        """
}

process split_chromosomes {
  input:
    tuple val(pop), path(bed), path(bim), path(fam), path(pheno), path(cov)
    each chrom
  output:
    tuple val(pop), val(chrom), path("${pop}_${chrom}.bed"), path("${pop}_${chrom}.bim"), path("${pop}_${chrom}.fam"), path(pheno), path("${pop}_${chrom}.cov"),  optional: true
  script:
  """
    plink2 --bfile ${bed.baseName} --chr ${chrom} --covar ${cov} --write-covar cols=fid --make-bed --out ${pop}_${chrom}
    sed -i "s/#//" ${pop}_${chrom}.cov
    # Remove files if the number of variants is less than the minimum specified
    if [ \$(wc -l < ${pop}_${chrom}.bim) -lt ${params.min_vars} ]; then
        rm ${pop}_${chrom}.*
    fi
  """
}

workflow BY_CHROMOSOME {
  take:
    plink_in
  main:
    // takes the bim file and extracts the chromosomes, so that chromosome-specific files can be created
    // running GWAS per chromosome makes the pipeline more scalable
    plink_in.map{it[2]} | get_chromosomes | splitText{it.trim()} | unique | set{ch_chromosomes}
    split_chromosomes(plink_in, ch_chromosomes)
  emit:
    split_chromosomes.out
}