process indexReference {

    tag "genome"
    container 'bioit-sample-processing:latest'

    input:
    path genome_fa

    output:
    path "hisat2_index", emit: index_dir

    script:
    """
    mkdir -p hisat2_index
    hisat2-build \
        -p ${task.cpus} \
        ${genome_fa} \
        hisat2_index/genome
    """
}
