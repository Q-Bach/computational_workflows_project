process HISAT2_BUILD {
    tag "$fasta"
    label 'process_high'
    label 'process_high_memory'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/hisat2:2.2.1--h1b792b2_3' :
        'quay.io/biocontainers/hisat2:2.2.1--h1b792b2_3' }"

    input:
    tuple val(meta), path(fasta)
    tuple val(meta2), path(gtf)
    val ch_threads
    val ch_ram

    output:
    tuple val(meta), path("hisat2") , emit: index
    path "versions.yml"             , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def ss = ''
    def exon = ''
    def extract_exons = ''
    def hisat2_build_memory = params.hisat2_build_memory ? (params.hisat2_build_memory as nextflow.util.MemoryUnit).toGiga() : 0
    """
    mkdir hisat2
    $extract_exons
    hisat2-build \\
        -p $ch_threads \\
        $ss \\
        $exon \\
        $args \\
        $fasta \\
        hisat2/${fasta.baseName}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hisat2: \$(hisat2 --version | grep -o 'version [^ ]*' | cut -d ' ' -f 2)
    END_VERSIONS
    """

    stub:
    """
    mkdir hisat2

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hisat2: \$(hisat2 --version | grep -o 'version [^ ]*' | cut -d ' ' -f 2)
    END_VERSIONS
    """
}
