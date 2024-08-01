process pack_out {
    input:
        path(plots)
        path(regenie)
    output:
        path("results.tar.gz")
    script:
        """
        mkdir plots regenie
        cp -r ${plots} plots/
        cp -r ${regenie} regenie/
        tar -czf results.tar.gz plots regenie
        """
}