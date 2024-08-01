nextflow.enable.dsl=2
nextflow.preview.output = true

include {stage} from "./modules/stage.nf";
include { CHECK_FILES } from './modules/input_checks.nf';
include {BY_POPULATION} from "./modules/populations.nf";
include {QC} from "./modules/qc.nf";
include {BY_CHROMOSOME} from "./modules/by_chromosomes.nf";
include {GWAS} from "./modules/gwas.nf";
include {pack_out} from "./modules/utils.nf";

workflow {
    // If running with local profile, files are downloaded
    // and set to their corresponding channels
    if (params.local) {
        stage(params.input_url)
        ch_bed = stage.out.bed
        ch_bim = stage.out.bim
        ch_fam = stage.out.fam
        ch_pheno = stage.out.pheno
        ch_bed.concat(ch_bim, ch_fam, ch_pheno)
        .collect()
        .set{ch_plink_in}

        ch_pheno = stage.out.pheno
        ch_samples = stage.out.samples

    } else {
        ch_bed = Channel.fromPath(params.bed)
        ch_bim = Channel.fromPath(params.bim)
        ch_fam = Channel.fromPath(params.fam)
        ch_pheno = Channel.fromPath(params.pheno)
        ch_samples = Channel.fromPath(params.samples)
        ch_plink_in = ch_bed.concat(ch_bim, ch_fam, ch_pheno).collect()
    }
    // Sanity checks of input files
    ch_bed.ifEmpty{exit 1, "No BED files found"}
    ch_bim.ifEmpty{exit 1, "No BIM files found"}
    ch_fam.ifEmpty{exit 1, "No FAM files found"}
    ch_pheno.ifEmpty{exit 1, "No phenotype files found"}
    ch_samples.ifEmpty{exit 1, "No samples files found"}

    // This module checks the input files for format and consistency
    // If any of the checks fail, the pipeline will exit with an error message
    CHECK_FILES(ch_plink_in.concat(ch_samples).collect())
    
    // Split dataset into populations
    BY_POPULATION(ch_samples, ch_plink_in)

    // QC. The following QC steps are performed:
    // 1. Check for missing data
    // 2. Check for minor allele frequency
    // 3. Check for Hardy-Weinberg equilibrium
    // 4. Generate plots for relevant QC metrics
    // 5. Perform population stratification (in case complex population structure is present)
    | QC
    // Split dataset by chromosome
    BY_CHROMOSOME(QC.out.plink)

    // // Run GWAS
    | GWAS

    // Organize ouptut
    pack_out(QC.out.plots, GWAS.out)
    // Show results location
    in_aws = params.aws
    out_files = pack_out.out
    workflow.onComplete {
        if (in_aws) {
            println("Results location: s3:/${out_files}")
        } else {
            println("Results location: ${out_files}")
        }
    }
    publish:
        pack_out.out >> "."
}

output {
    directory "results"
    mode "copy"
}