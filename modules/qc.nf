process check_missing {
    input:
        tuple val(pop), path(bed), path(bim), path(fam), path(pheno)
    output:
        path("${pop}.*miss")
    script:
        """
        plink2 --bfile ${pop} --pheno ${pheno} --missing --out ${pop}
        """
}

process check_maf {
    input:
        tuple val(pop), path(bed), path(bim), path(fam), path(pheno)
    output:
        path("${pop}.afreq")
    script:
        """
        plink2 --bfile ${pop} --pheno ${pheno} --freq --out ${pop}
        """
}

process plot_checks {
    input:
        tuple path(smiss), path(vmiss), path(maf_freq)
    output:
        path("*.svg"), optional: true
    script:
        """
        gather_checks.py ${smiss.baseName} ${smiss} ${vmiss} ${maf_freq}
        """
}

process stratication {
    input:
        tuple val(pop), path(bed), path(bim), path(fam), path(pheno)
    output:
        tuple val(pop), path("${pop}.eigenvec")
    script:
    """
    plink2 --bfile ${pop} --pheno ${pheno} --freq counts --pca allele-wts vcols=chrom,ref,alt --out ${pop} 
    """
}

process filter_qc {
  input:
    tuple val(pop), path(bed), path(bim), path(fam), path(pheno), path(covar)
  output:
    tuple val(pop), path("filtered_qc_${pop}.bed"), path("filtered_qc_${pop}.bim"), path("filtered_qc_${pop}.fam"), path(pheno), path("filtered_qc_${pop}.cov")
  script:
    """
    plink2 --bfile ${pop} --pheno ${pheno} --make-bed --out filtered_qc_${pop} \
    --geno ${params.var_missing} --mind ${params.sample_missing} --maf ${params.maf} \
    --covar ${covar} --write-covar cols=fid \
    ${params.hwe < 1? "--hwe "+ params.hwe + " midp keep-fewhet": ""}
    """
}

workflow QC {
    take:
        data
    main:
        //check_missing and check_maf are processes that check for missing data and minor allele frequency
        // they are used to generate plots with plot_checks, if there is relevant data
        check_missing(data).concat(check_maf(data)).flatten()
        .map{[it.baseName, it]}.groupTuple(size:3).map{it[1]} | plot_checks | collect | set{qc_out}
        // checks for further population stratification, and outputs the eigenvector file, that will be
        // used as covariates for GWAS
        stratication(data)
        data.join(stratication.out).set{data_pca}
        // Generate filtered data for GWAS
        filter_qc(data_pca)
    emit:
        plots = qc_out
        plink = filter_qc.out   
}