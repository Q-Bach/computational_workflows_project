/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC                     } from '../../modules/nf-core/fastqc/main'
include { TRIMGALORE                 } from '../../modules/nf-core/trimgalore/main'
include { HISAT2_ALIGN               } from '../../modules/nf-core/hisat2/align/main'
include { HISAT2_BUILD               } from '../../modules/nf-core/hisat2/build/main'
include { SAMTOOLS_SORT              } from '../../modules/nf-core/samtools/sort/main'
include { SUBREAD_FEATURECOUNTS      } from '../../modules/nf-core/subread/featurecounts/main'
include { GENERATE_FEATURECOUNT_PLOT } from '../../modules/local/generate_counts/main'

/*
------------------------------------------------------------
   MAIN WORKFLOW
-------------------------------------------------------------
*/

workflow TEST {

    main:

    // create versions channel

    GENERATE_FEATURECOUNT_PLOT()
  
}