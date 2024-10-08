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

workflow RNASEQ {

    take:
    ch_samplesheet

    main:
    // Read in the samplesheet

    ch_fastq = ch_samplesheet
        .splitCsv(header: true)
        .map { row -> 
        if (row.fastq_2) {
            [["single_end": false, "sample" : row.sample, "strandedness": row.strandedness], [file(row.fastq_1), file(row.fastq_2)]]
        } else {
            [["single_end": true, "sample" : row.sample, "strandedness": row.strandedness], [file(row.fastq_1)]]
        }
        }
        .view()

        /* .map {
            checkSamplesAfterGrouping(it)
        } */

    //TODO 2: FASTQC

    FASTQ_FASTQC(ch_fastq)

    ch_fastqc_html = FASTQ_FASTQC.out.fastqc_html
    ch_fastqc_zip = FASTQ_FASTQC.out.fastqc_zip

    //TODO 3: TRIMGALORE to trim the reads
    

    //TODO 4: ALIGNING THE READS

}