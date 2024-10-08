#!/usr/bin/env nextflow

include { RNASEQ } from "./workflows/rnaseq"

workflow {

    main:
    // read in samplesheet
    ch_samplesheet = Channel.value(file(params.input, checkIfExists: true))

    // run main workflow
    RNASEQ(ch_samplesheet)

}