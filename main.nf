#!/usr/bin/env nextflow


include { RNASEQ } from "./workflows/rnaseq/main"

workflow {

main:
    // read in samplesheet
    ch_samplesheet = Channel.value(file(params.input, checkIfExists: true))
    // read in path to fasta, transcripts fasta and gtf file
    ch_fasta = Channel.value(file(params.fasta, checkIfExists: true))
    ch_gtf = Channel.value(file(params.gtf, checkIfExists: true))
    // read in parameters for available threads and ram
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
