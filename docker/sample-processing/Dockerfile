FROM condaforge/miniforge3:24.3.0-0

LABEL description="seqkit fastp hisat2 samtools"

RUN conda install -y -c bioconda -c conda-forge \
    seqkit=2.8.2 \
    fastp=0.23.4 \
    hisat2=2.2.1 \
    samtools=1.20 \
    && conda clean -afy

WORKDIR /data
