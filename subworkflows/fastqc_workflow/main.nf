include { FASTQC           } from '../../modules/nf-core/fastqc/main'



workflow FASTQ_FASTQC {
    take:
    reads             // channel: [ val(meta), [ reads ] ]
    //skip_fastqc       // boolean: true/false

    main:
    ch_versions = Channel.empty()
    fastqc_html = Channel.empty()
    fastqc_zip  = Channel.empty()
    FASTQC (reads)
        fastqc_html = FASTQC.out.html
        fastqc_zip  = FASTQC.out.zip
        ch_versions = ch_versions.mix(FASTQC.out.versions.first())

    emit:

    fastqc_html        // channel: [ val(meta), [ html ] ]
    fastqc_zip         // channel: [ val(meta), [ zip ] ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]
}