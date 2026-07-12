process multiQC {

    tag "multiqc"
    container 'bioit-sample-qc:latest'

    input:
    path multiqc_files

    output:
    path "multiqc_report.html"      , emit: report
    path "multiqc_report_data/"     , emit: data

    script:
    """
    multiqc . \
        --filename multiqc_report.html \
        --force
    """
}
