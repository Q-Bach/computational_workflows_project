/*
----------
  IMPORT
----------
*/

include { FASTQC                     } from '../../modules/nf-core/fastqc/main'
include { TRIMGALORE                 } from '../../modules/nf-core/trimgalore/main'
include { HISAT2_ALIGN               } from '../../modules/nf-core/hisat2/align/main'
include { HISAT2_BUILD               } from '../../modules/nf-core/hisat2/build/main'
include { SAMTOOLS_SORT              } from '../../modules/nf-core/samtools/sort/main'
include { SUBREAD_FEATURECOUNTS      } from '../../modules/nf-core/subread/featurecounts/main'
include { GENERATE_FEATURECOUNT_PLOT } from '../../modules/local/generate_counts/main'

/*
-----------------
  MAIN WORKFLOW
-----------------
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

    // create versions channel

    ch_versions = channel.empty()

    // Read in the samplesheet
    ch_fastq = ch_samplesheet
        .splitCsv(header: true)
        .map{row -> 
        if (row.fastq_2) {
            [
              ["single_end": false, "sample" : row.sample, "strandedness": row.strandedness],
              [file(row.fastq_1), file(row.fastq_2)]
            ]
        } else {
            [
              ["single_end": true, "sample" : row.sample, "strandedness": row.strandedness],
              [file(row.fastq_1)]
            ]
        }
        }
        

    /* 
    ----------
      FASTQC
    ----------
    */

    // call the fastqc module from nf-core
    FASTQC(ch_fastq)

    // parse output
    ch_fastqc_html = FASTQC.out.html
    ch_fastqc_zip = FASTQC.out.zip
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    // store the output files
    ch_fastqc_html.map(item -> item.last()).flatten().collectFile(storeDir:"$ch_outfolder/fastqc")
    ch_fastqc_zip.map (item -> item.last()).flatten().collectFile(storeDir:"$ch_outfolder/fastqc")  

    /* 
    ----------------------------
      TRIMMING WITH TRIMGALORE
    ----------------------------
    */

    // call the trimgalore module from nf-core
    TRIMGALORE (ch_fastq)

    // parse the output from trimgalore 
    ch_trim_reads       = TRIMGALORE.out.reads
    ch_trim_unpaired    = TRIMGALORE.out.unpaired
    ch_trim_html        = TRIMGALORE.out.html
    ch_trim_zip         = TRIMGALORE.out.zip
    ch_trim_log         = TRIMGALORE.out.log
    ch_versions         = ch_versions.mix(TRIMGALORE.out.versions.first())

    // store the files 
    ch_trim_reads.map(item -> item.last()).flatten().collectFile(storeDir:"$ch_outfolder/trimgalore")
    ch_trim_html.map (item -> item.last()).flatten().collectFile(storeDir:"$ch_outfolder/trimgalore")
    ch_trim_zip.map  (item -> item.last()).flatten().collectFile(storeDir:"$ch_outfolder/trimgalore")
    ch_trim_log.map  (item -> item.last()).flatten().collectFile(storeDir:"$ch_outfolder/trimgalore")
   
    /* 
    ------------------------
      ALIGNING WITH HISAT2
    ------------------------
    */
    
    // build index for hisat2 align (necessary input) by calling HISAT2_BUILD module from nf-core
    HISAT2_BUILD (
        ch_fasta.map{[[:], it]},
        ch_gtf.map  {[[:], it]},
        ch_threads,
        ch_ram
      )

    // parse output of Hisat2_build
    ch_hisat2_index = HISAT2_BUILD.out.index
    ch_versions     = ch_versions.mix(HISAT2_BUILD.out.versions.first())

    // align trimmed reads with HISAT2 by calling hisat2_align module from nf-core
    HISAT2_ALIGN(ch_trim_reads, ch_hisat2_index)
    
    // access the output of hisat2_align
    ch_hisat2_bam = HISAT2_ALIGN.out.bam
    ch_hisat2_summary = HISAT2_ALIGN.out.summary
    ch_versions = ch_versions.mix(HISAT2_ALIGN.out.versions.first()) 
    // store output
    ch_hisat2_bam.map    (item -> item.last()).collectFile(storeDir: "$ch_outfolder/hisat2")
    ch_hisat2_summary.map(item -> item.last()).collectFile(storeDir: "$ch_outfolder/hisat2")

    /* 
    --------------------------------------------
      READ COUNT WITH SAMTOOLS + FEATURECOUNTS
    --------------------------------------------
    */

    // sort alignment file with samtools nf-core module
    SAMTOOLS_SORT (ch_hisat2_bam, ch_fasta.map {[[:], it]})

    // parse output and store to file
    ch_bam_sorted = SAMTOOLS_SORT.out.bam.map(item -> item.last()).collectFile(storeDir: "$ch_outfolder/samtools")
    ch_versions = ch_versions.mix(SAMTOOLS_SORT.out.versions.first())

    // count features with the subread featurecounts module of nf-core
    SUBREAD_FEATURECOUNTS(ch_bam_sorted.combine(ch_gtf).map{[["sample": it.first().baseName.replaceAll("_sorted", "")], it.first(), it.last()]})
    
    // store output
    ch_featurecounts          = SUBREAD_FEATURECOUNTS.out.counts.map (item -> item.last()).collectFile(storeDir: "$ch_outfolder/counts")
    ch_featurecounts_summary  = SUBREAD_FEATURECOUNTS.out.summary.map(item -> item.last()).collectFile(storeDir: "$ch_outfolder/counts")
    ch_versions = ch_versions.mix(SUBREAD_FEATURECOUNTS.out.versions.first())

     /* 
    ------------
      VERSIONS
    ------------
    */

    // save the versions in a file
    ch_versions.collectFile(storeDir: "$ch_outfolder/versions")
  
}