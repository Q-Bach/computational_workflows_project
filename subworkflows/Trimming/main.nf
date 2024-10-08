//
// Trimming
//

include { TRIMGALORE } from '../../../modules/nf-core/trimgalore/main'

workflow Trimming {

    take:
    reads             // channel: [ val(meta), [ reads ] ]
    min_trimmed_reads // integer: > 0

    
    main:
    trim_unpaired   = Channel.empty()
    trim_html       = Channel.empty()
    trim_zip        = Channel.empty()
    trim_log        = Channel.empty()
    trim_read_count = Channel.empty()

    TRIMGALORE (umi_reads)
        trim_unpaired = TRIMGALORE.out.unpaired
        trim_html     = TRIMGALORE.out.html
        trim_zip      = TRIMGALORE.out.zip
        trim_log      = TRIMGALORE.out.log
        ch_versions   = ch_versions.mix(TRIMGALORE.out.versions.first())

        //
        // Filter FastQ files based on minimum trimmed read count after adapter trimming
        //

        TRIMGALORE
            .out
            .reads
            .join(trim_log, remainder: true)
            .map {
                meta, reads, trim_log ->
                    if (trim_log) {
                        num_reads = getTrimGaloreReadsAfterFiltering(meta.single_end ? trim_log : trim_log[-1])
                        [ meta, reads, num_reads ]
                    } else {
                        [ meta, reads, min_trimmed_reads.toFloat() + 1 ]
                    }
            }
            .set { ch_num_trimmed_reads }

        ch_num_trimmed_reads
            .filter { meta, reads, num_reads -> num_reads >= min_trimmed_reads.toFloat() }
            .map { meta, reads, num_reads -> [ meta, reads ] }
            .set { trim_reads }

        ch_num_trimmed_reads
            .map { meta, reads, num_reads -> [ meta, num_reads ] }
            .set { trim_read_count }
    }

    emit:
    reads = trim_reads // channel: [ val(meta), [ reads ] ]

    trim_unpaired      // channel: [ val(meta), [ reads ] ]
    trim_html          // channel: [ val(meta), [ html ] ]
    trim_zip           // channel: [ val(meta), [ zip ] ]
    trim_log           // channel: [ val(meta), [ txt ] ]
    trim_read_count    // channel: [ val(meta), val(count) ]

    versions = ch_versions.ifEmpty(null) // channel: [ versions.yml ]

}