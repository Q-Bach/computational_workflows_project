#!/usr/bin/env nextflow


include { RNASEQ } from "./workflows/rnaseq/main"

workflow {

    main:
    // read in samplesheet
    ch_samplesheet = Channel.value(file(params.input, checkIfExists: true))
    ch_fasta = Channel.value(file(params.fasta, checkIfExists: true))
    ch_gtf = Channel.value(file(params.gtf, checkIfExists: true))
    ch_threads = Channel.value(params.threads)
    ch_ram = Channel.value(params.ram)

    // run main workflow
    RNASEQ(
        ch_samplesheet,
        params.outdir,
        ch_fasta,
        ch_gtf,
        ch_threads,
        ch_ram
        )
}
