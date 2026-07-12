process makeSummary {

    tag "cohort"
    container 'bioit-sample-qc:latest'

    input:
    path reports

    output:
    path "cohort_summary.tsv", emit: summary

    script:
    """
    head -n1 \$(ls *.report.tsv | sort | head -1) > cohort_summary.tsv
    tail -n+2 -q *.report.tsv | sort -k1,1 >> cohort_summary.tsv
    """
}
