process preprocessReads {

    tag "${meta.id}"
    container 'bioit-sample-processing:latest'

    input:
    tuple val(meta), path(fastq_1), path(fastq_2)

    output:
    tuple val(meta), path("${meta.id}_R1.trimmed.fastq.gz"), path("${meta.id}_R2.trimmed.fastq.gz"), emit: reads
    tuple val(meta), path("${meta.id}_fastp.json") , emit: json
    tuple val(meta), path("${meta.id}_fastp.html") , emit: html
    tuple val(meta), path("${meta.id}_fastp.log")  , emit: log

    script:
    """
    fastp \
        --in1 ${fastq_1} \
        --in2 ${fastq_2} \
        --out1 ${meta.id}_R1.trimmed.fastq.gz \
        --out2 ${meta.id}_R2.trimmed.fastq.gz \
        --json ${meta.id}_fastp.json \
        --html ${meta.id}_fastp.html \
        --thread ${task.cpus} \
        2> ${meta.id}_fastp.log
    """
}
