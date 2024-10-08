/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//

//
// SUBWORKFLOWS:
//
include { Trimming } from '../../subworkflows/Trimming'
include { FASTQ_FASTQC } from '../../subworkflows/fastqc_workflow'

//
// PLUGINS: Installed directly from nf-core/modules
//
include { fromSamplesheet } from 'plugin/nf-validation' //used to read the sample sheet

workflow RNASEQ {

    take:
    ch_samplesheet

    main:
    // Read in the samplesheet

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

    FASTQ_FASTQC(ch_fastq)

    ch_fastqc_html = FASTQ_FASTQC.out.fastqc_html
    ch_fastqc_zip = FASTQ_FASTQC.out.fastqc_zip

    //TODO 3: TRIMGALORE to trim the reads
    

    //TODO 4: ALIGNING THE READS

}