process GENERATE_FEATURECOUNT_PLOT {

    debug true

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-a97e90b3b802d1da3d6958e0867610c718cb5eb1:2cdf6bf1e92acbeb9b2834b1c58754167173a410-0' :
        'community.wave.seqera.io/library/pip_matplotlib_numpy_pandas:173a63ad006cb1c5' }"

    output:
    stdout()

    script:
    """
    ls
    """
}