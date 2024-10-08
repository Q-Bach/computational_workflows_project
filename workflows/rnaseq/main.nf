/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//

//
// Plug-ins: Installed directly from nf-core/modules
//
include { samplesheetToList } from 'plugin/nf-schema' //used to read the sample sheet

workflow RNASEQ {

    take:
    ch_samplesheet

    main:
    //TODO 1: Read in the samplesheet

    ch_fastq = channel
        .fromSamplesheet("input")
        .map {
            meta, fastq_1, fastq_2 ->
                if (!fastq_2) {
                    return [ meta.id, meta + [ single_end:true ], [ fastq_1 ] ]
                } else {
                    return [ meta.id, meta + [ single_end:false ], [ fastq_1, fastq_2 ] ]
                }
        }
        .groupTuple()
        .map {
            checkSamplesAfterGrouping(it)
        }
        .view()

    //TODO 2: FASTQC

    //TODO 3: TRIMGALORE to trim the reads

    //TODO 4: ALIGNING THE READS

}