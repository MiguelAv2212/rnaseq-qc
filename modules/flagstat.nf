process flagstat {

    tag "${meta.id}"
    container 'bioit-sample-processing:latest'

    input:
    tuple val(meta), path(bam), path(bai)

    output:
    tuple val(meta), path("${meta.id}.flagstat.txt"), emit: flagstat

    script:
    """
    samtools flagstat ${bam} > ${meta.id}.flagstat.txt
    """
}
