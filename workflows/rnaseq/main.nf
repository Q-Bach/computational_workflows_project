/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { FASTQC           } from '../../modules/nf-core/fastqc/main'
include { TRIMGALORE } from '../../modules/nf-core/trimgalore/main'
include { HISAT2_ALIGN } from '../../modules/nf-core/hisat2/align/main'
include { HISAT2_BUILD} from '../../modules/nf-core/hisat2/build/main'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
------------------------------------------------------------
   MAIN WORKFLOW
-------------------------------------------------------------
*/


workflow RNASEQ {

    take:
    ch_samplesheet
    ch_outfolder
    ch_fasta
    ch_gtf
    ch_threads
    ch_ram

    main:

    /* 
    -----------------
      VERSIONS
    -----------------
    */

    ch_versions = channel.empty()

    /* 
    -----------------
      SAMPLESHEET
    -----------------
    */

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
        

    /* 
    -----------------
      FASTQC
    -----------------
    */
    FASTQC(ch_fastq)

    ch_fastqc_html = FASTQC.out.html
    ch_fastqc_zip = FASTQC.out.zip

    ch_fastqc_html.map( item -> item.last() ).flatten().collectFile(storeDir:"$ch_outfolder/fastqc")
    ch_fastqc_zip.map( item -> item.last() ).flatten().collectFile(storeDir:"$ch_outfolder/fastqc")

    ch_versions = ch_versions.mix(FASTQC.out.versions.first())


    /* 
    -------------------------
      TRIMMING W/ TRIMGALORE
    -------------------------
    */

    
    TRIMGALORE (ch_fastq)

    ch_trim_reads       = TRIMGALORE.out.reads
    /* ch_trim_unpaired    = TRIMGALORE.out.unpaired
    ch_trim_html        = TRIMGALORE.out.html
    ch_trim_zip         = TRIMGALORE.out.zip
    ch_trim_log         = TRIMGALORE.out.log */
    
    ch_versions         = ch_versions.mix(TRIMGALORE.out.versions.first())
    ch_trim_reads.map( item -> item.last() ).flatten().collectFile(storeDir:"$ch_outfolder/trimgalore")
   
    /* 
    -------------------------
      ALIGNING W/ HISAT2
    -------------------------
    */

    ch_fasta.view()
    ch_gtf.view()

    ch_hisat2_index = HISAT2_BUILD (
        ch_fasta.map { [ [:], it ] },
        ch_gtf.map { [ [:], it ] },
        ch_threads,
        ch_ram)

    /* HISAT2_ALIGN ( ch_fastq, index, splicesites )
    ch_hisat2_summary = HISAT2_ALIGN.out.summary.view()
    ch_versions = ch_versions.mix(HISAT2_ALIGN.out.versions.first()) */

    

}