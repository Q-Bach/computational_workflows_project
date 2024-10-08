/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT NF-CORE MODULES/SUBWORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// MODULE: Installed directly from nf-core/modules
//
include { TRIMGALORE } from '../modules/nf-core/trimgalore/main'       
include { FASTQC } from '../modules/nf-core/fastqc/main'       


workflow rna-seq {

    //TODO 1: Read in the samplesheet 

    //TODO 2: FASTQC

    //TODO 3: TRIMGALORE to trim the reads

    //TODO 4: ALIGNING THE READS

}