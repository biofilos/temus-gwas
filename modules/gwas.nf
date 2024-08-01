process regenie_step1 {
    input:
        tuple val(pop), val(chrom), path(bed), path(bim), path(fam), path(pheno), path(cov)
    output:
        tuple val(pop), val(chrom), path(bed), path(bim), path(fam), path(pheno), path("preds.tar.gz"), path("regenie_1_${pop}_${chrom}_pred.list"), path(cov)
    script:
        """
            regenie --step 1 --bed ${pop}_${chrom} --phenoFile ${pheno} --covarFile ${cov} --bsize 1000 --out regenie_1_${pop}_${chrom}
            tar czf preds.tar.gz regenie_1_${pop}_${chrom}*.loco
        """
}

process regenie_step2 {
    input:
        tuple val(pop), val(chrom), path(bed), path(bim), path(fam), path(pheno), path(preds), path(step1_list), path(cov)
    output:
        path("regenie2_${pop}_${chrom}*")
    script:
        """
        # incompres prediction from first step
        tar xf ${preds}
        # remove path for files
        sed -i 's+/.*/++' ${step1_list}
        regenie --step 2 --bed ${pop}_${chrom} --phenoFile ${pheno} --covarFile ${cov} \
        --firth --approx --pThresh 0.01 --pred ${step1_list} --bsize 400 --out regenie2_${pop}_${chrom}
        """
}

workflow GWAS {
    take:
        plink_in
    main:
        // step 1 of regenie runs with default parameters
        // In step 2, the firth logistic regression is used to reduce the bias
        // from maximum likelihood estimates
        // The --approx option is used to speed up the computation
        // The --pThresh option is used to set the p-value threshold for the approximate Firth test
        regenie_step1(plink_in) | regenie_step2 | collect | set{regenie_out}
    emit:
        regenie_out
}