#!/usr/bin/env nextflow

nextflow.enable.strict = true
nextflow.enable.types = true

record ReconMeta {
    bcl_name: String
    recon_name: String
    bead: Integer?
    diameter: Float?
    knn_filter: Boolean
    n_neighbors: Integer?
    local_connectivity: Integer?
    spread: Float?
    min_dist: Float?
    repulsion_strength: Float?
    negative_sample_rate: Integer?
    n_epochs: Integer?
}

process RECON {
    tag "${meta.recon_name}${meta.n_epochs ? "_ne${meta.n_epochs}" : ""}"
    container 'quay.io/broadinstitute/macosko-pipelines_reconstruction:current'
    containerOptions workflow.containerEngine in ['docker', 'podman'] ? '--entrypoint ""' : null
    label 'process_high'
    label 'process_long'

    input:
    record(
        meta: ReconMeta,
        recon_count_and_knn_files: List<Path>
    )

    stage:
    stageAs recon_count_and_knn_files, "recon-count/${meta.bcl_name}/${meta.recon_name}/*"

    output:
    record(
        meta: meta,
        recon_files: files("UMAP*/*").toSorted()
    )

    script:
    def args = task.ext.args
    """
    MAMBA_ROOT_PREFIX=/root/micromamba /root/.local/bin/micromamba run \\
        python \\
        /usr/local/bin/reconstruction/recon.py \\
        --in_dir recon-count/${meta.bcl_name}/${meta.recon_name} \\
        --out_dir . \\
        ${args}
    """

    stub:
    """
    mkdir -p UMAP_stub
    cat > UMAP_stub/summary.pdf <<PDFEOF
    %PDF-1.0
    1 0 obj<</Pages 2 0 R>>
    2 0 obj<</Count 1/Kids[3 0 R]>>
    3 0 obj<</Parent 2 0 R>>
    trailer<</Root 1 0 R>>
    %%EOF
    PDFEOF
    """
}
