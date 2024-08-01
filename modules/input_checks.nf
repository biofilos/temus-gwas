process check_bim {
    input:
        path(bim)
    output:
        stdout
    script:
        """
        check_bim_fam.py ${bim} BIM
        """
}

process check_fam {
    input:
        path(fam)
    output:
        stdout
    script:
        """
        check_bim_fam.py ${fam} FAM
        """
}

process check_pheno {
    input:
        path(pheno)
    output:
        stdout
    script:
        """
        check_pheno.py ${pheno}
        """
}

process check_samples {
  input:
    path(samples)
  output:
    stdout
  script:
  """
    check_samples.py ${samples}
  """
}


workflow CHECK_FILES {
    take:
        files
    main:
        files
        .map{
            [bim: it[1],
             fam: it[2],
             phe: it[3],
             samples: it[4]]
        }.set{data}
        // each of these scripts will exit with an error 
        // message if the input file is not in the expected format
        check_bim(data.bim)
        check_fam(data.fam)
        check_pheno(data.phe)
        check_samples(data.samples)
        
    emit:
        // in case a future version of the pipeline needs it
        // these are the status of the checks
        bim = check_bim.out
        fam = check_fam.out
        pheno = check_pheno.out
}