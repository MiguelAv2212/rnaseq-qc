process generateSampleReport {

    tag "${meta.id}"
    container 'bioit-sample-qc:latest'

    input:
    tuple val(meta), path(fastp_json), path(flagstat), path(seqkit_r1), path(seqkit_r2)
    val min_retained_percentage
    val min_mapped_percentage

    output:
    path "${meta.id}.report.tsv", emit: report

    script:
    """
    generate_report.py \
        --sample ${meta.id} \
        --fastp-json ${fastp_json} \
        --flagstat ${flagstat} \
        --seqkit-r1 ${seqkit_r1} \
        --seqkit-r2 ${seqkit_r2} \
        --min-retained ${min_retained_percentage} \
        --min-mapped ${min_mapped_percentage} \
        --output ${meta.id}.report.tsv
    """
}
