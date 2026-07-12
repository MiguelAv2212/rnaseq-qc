process validateInputs {

    tag "${meta.id}"
    container 'bioit-sample-processing:latest'

    input:
    tuple val(meta), path(fastq_1), path(fastq_2)

    output:
    tuple val(meta), path("${meta.id}_r1.stats"), path("${meta.id}_r2.stats")

    script:
    """
    seqkit stats -T ${fastq_1} > ${meta.id}_r1.stats
    seqkit stats -T ${fastq_2} > ${meta.id}_r2.stats

    R1_COUNT=\$(tail -n1 ${meta.id}_r1.stats | cut -f4 | tr -d ',')
    R2_COUNT=\$(tail -n1 ${meta.id}_r2.stats | cut -f4 | tr -d ',')

    if [ "\$R1_COUNT" != "\$R2_COUNT" ]; then
        echo "ERROR: ${meta.id} has mismatched read counts: R1=\$R1_COUNT R2=\$R2_COUNT" >&2
        exit 1
    fi
    echo "Sample ${meta.id}: R1=\$R1_COUNT R2=\$R2_COUNT OK" >&2
    """
}
