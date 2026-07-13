# RNA-seq Intake Quality Control Pipeline

Dockerized Nextflow DSL2 pipeline for automated intake QC of paired-end RNA-seq libraries.

## Pipeline overview

1. **validateInputs** — checks FASTQ consistency and read count parity (seqkit)
2. **preprocessReads** — adapter trimming and quality filtering (fastp)
3. **indexReference** — builds HISAT2 index from reference genome (once per run)
4. **align** — aligns reads and produces sorted BAM (HISAT2 + samtools sort via pipe)
5. **flagstat** — alignment QC metrics (samtools flagstat)
6. **generateSampleReport** — per-sample ACCEPT/REVIEW decision based on thresholds
7. **makeSummary** — cohort-level TSV summary sorted by sample ID
8. **multiQC** — aggregated HTML report (fastp + HISAT2 + samtools)

## Requirements

- Docker
- Java 11+
- Nextflow >= 24.10.0

## Docker build

```bash
docker build -t bioit-sample-processing:latest docker/sample-processing/
docker build -t bioit-sample-qc:latest docker/sample-qc/
```

## Run the pipeline

```bash
nextflow run main.nf \
    -profile docker \
    --input samplesheet.csv \
    --genome data/genome.fa \
    --outdir results \
    --min_retained_percentage 90 \
    --min_mapped_percentage 70
```

## Reproducibility test

Run twice with `-resume` to confirm caching:

```bash
nextflow run main.nf -profile docker --input samplesheet.csv \
    --genome data/genome.fa --outdir results \
    --min_retained_percentage 90 --min_mapped_percentage 70 -resume
```

Change only the mapped threshold — upstream steps remain cached:

```bash
nextflow run main.nf -profile docker --input samplesheet.csv \
    --genome data/genome.fa --outdir results \
    --min_retained_percentage 90 --min_mapped_percentage 95 -resume
```

## Results directory tree

```

results/
├── cohort_summary.tsv
├── multiqc/
│   └── multiqc_report.html
├── pipeline_info/
│   ├── execution_report_min-retained-90.html
│   ├── execution_timeline.html
│   ├── execution_trace.tsv
│   └── workflow_dag.html
├── qc/
│   ├── fastp/
│   │   ├── ENCSR000COQ1_fastp.html
│   │   ├── ENCSR000COQ1_fastp.json
│   │   ├── ENCSR000COR1_fastp.html
│   │   ├── ENCSR000COR1_fastp.json
│   │   ├── ENCSR000CPO1_fastp.html
│   │   └── ENCSR000CPO1_fastp.json
│   └── flagstat/
│       ├── ENCSR000COQ1.flagstat.txt
│       ├── ENCSR000COR1.flagstat.txt
│       └── ENCSR000CPO1.flagstat.txt
└── reports/
├── ENCSR000COQ1.report.tsv
├── ENCSR000COR1.report.tsv
└── ENCSR000CPO1.report.tsv
```

## Execution reports

Pre-generated execution reports are available in `pipeline_info/`:
- `execution_report_min-retained-90.html` — full task execution report
- `execution_timeline.html` — timeline of task execution
- `workflow_dag.html` — pipeline DAG visualization

## Samplesheet format

```csv
sample,fastq_1,fastq_2
SAMPLE1,data/reads/SAMPLE1_1.fastq.gz,data/reads/SAMPLE1_2.fastq.gz
```