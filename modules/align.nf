process align {

    tag "${meta.id}"
    container 'bioit-sample-processing:latest'

    input:
    tuple val(meta), path(fastq_1), path(fastq_2)
    path index_dir

    output:
    tuple val(meta), path("${meta.id}.sorted.bam"), path("${meta.id}.sorted.bam.bai"), emit: bam
    tuple val(meta), path("${meta.id}.hisat2.log") , emit: log

    script:
    """
    hisat2 \
        -x ${index_dir}/genome \
        -1 ${fastq_1} \
        -2 ${fastq_2} \
        -p ${task.cpus} \
        2> ${meta.id}.hisat2.log \
    | samtools sort \
        -@ ${task.cpus} \
        -o ${meta.id}.sorted.bam

    samtools index ${meta.id}.sorted.bam
    """
}
