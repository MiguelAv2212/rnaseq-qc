process indexReference {

    tag "genome"
    container 'bioit-sample-processing:latest'

    input:
    path ref_dir
    val genome_prefix

    output:
    val true, emit: done

    script:
    """
    hisat2-build \
        -p ${task.cpus} \
        ${ref_dir}/${genome_prefix}.fa \
        ${ref_dir}/${genome_prefix}
    """
}
