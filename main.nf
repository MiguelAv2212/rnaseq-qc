#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

include { validateInputs       } from './modules/validate_inputs'
include { preprocessReads      } from './modules/preprocess_reads'
include { indexReference       } from './modules/index_reference'
include { align                } from './modules/align'
include { flagstat             } from './modules/flagstat'
include { generateSampleReport } from './modules/generate_sample_report'
include { makeSummary          } from './modules/make_summary'
include { multiQC              } from './modules/multiqc'

workflow {

    main:
    // Parameter validation
    ['input','genome','outdir','min_retained_percentage','min_mapped_percentage'].each { p ->
        if (params[p] == 'undefined' || params[p] == null) {
            error "ERROR: --${p} is required but was not provided."
        }
    }

    // Parse samplesheet into [meta, fastq_1, fastq_2]
    reads_ch = Channel.fromPath(params.input)
        .splitCsv(header: true)
        .map { row -> tuple([id: row.sample], file(row.fastq_1), file(row.fastq_2)) }

    // Step 1 — Validate inputs
    validateInputs(reads_ch)

    // Step 2 — Preprocess reads
    preprocessReads(reads_ch)

    // Step 3 — Index reference (once)
    indexReference(file(params.genome))

    // Step 4 — Align
    align(preprocessReads.out.reads, indexReference.out.index_dir)

    // Step 5 — Flagstat
    flagstat(align.out.bam)

    // Combine metrics for per-sample report
    report_ch = validateInputs.out
        .join(preprocessReads.out.json)
        .join(flagstat.out.flagstat)
        .map { meta, r1_stats, r2_stats, fastp_json, flagstat_txt ->
            tuple(meta, fastp_json, flagstat_txt, r1_stats, r2_stats)
        }

    // Step 6 — Per-sample report
    generateSampleReport(
        report_ch,
        params.min_retained_percentage,
        params.min_mapped_percentage
    )

    // Step 7 — Cohort summary
    makeSummary(generateSampleReport.out.report.toList())

    // Step 8 — MultiQC
    multiqc_files = preprocessReads.out.json.map { meta, f -> f }
        .mix(preprocessReads.out.log.map  { meta, f -> f })
        .mix(align.out.log.map            { meta, f -> f })
        .mix(flagstat.out.flagstat.map    { meta, f -> f })
        .toList()

    multiQC(multiqc_files)

    publish:
    fastp_json     = preprocessReads.out.json.map    { meta, f -> f }
    fastp_html     = preprocessReads.out.html.map    { meta, f -> f }
    flagstat_files = flagstat.out.flagstat.map        { meta, f -> f }
    sample_reports = generateSampleReport.out.report
    cohort_summary = makeSummary.out.summary
    multiqc_report = multiQC.out.report
}

output {
    fastp_json {
        path 'qc/fastp'
    }
    fastp_html {
        path 'qc/fastp'
    }
    flagstat_files {
        path 'qc/flagstat'
    }
    sample_reports {
        path 'reports'
    }
    cohort_summary {
        path '.'
    }
    multiqc_report {
        path 'multiqc'
    }
}
