#!/usr/bin/env nextflow

nextflow.enable.strict = true
nextflow.enable.types = true

include { paramsSummaryLog ; validateParameters } from 'plugin/nf-schema'
include { calcReconResources; ReconResourcesInput } from './subworkflows/local/utils_recon'
include { WF_RECON; WfReconInput } from './workflows/local/wf_recon'

params {
    recon_count_and_knn_dir: Path?
    recon_dir: Path?
    bcl_name: String?
    recon_name: String?
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
    help: Boolean
    help_full: Boolean
    show_hidden: Boolean
}

workflow {
    main:
    if (params.help || params.help_full) {
        // https://github.com/nextflow-io/nextflow/issues/3984
        exit(0, '')
    }
    validateParameters()

    def recon_resources = calcReconResources(record(
        recon_count_and_knn_dir: params.recon_count_and_knn_dir,
        recon_dir: params.recon_dir,
        bcl_name: params.bcl_name,
        recon_name: params.recon_name,
    ) as ReconResourcesInput)

    log.info(paramsSummaryLog(workflow))

    def val_recon = WF_RECON(
        record(
            meta: record(
                bcl_name: recon_resources.bcl_name,
                recon_name: recon_resources.recon_name,
                bead: params.bead,
                diameter: params.diameter,
                knn_filter: params.knn_filter,
                n_neighbors: params.n_neighbors,
                local_connectivity: params.local_connectivity,
                spread: params.spread,
                min_dist: params.min_dist,
                repulsion_strength: params.repulsion_strength,
                negative_sample_rate: params.negative_sample_rate,
                n_epochs: params.n_epochs
            ),
            recon_count_and_knn_files: recon_resources.recon_count_and_knn_files
        ) as WfReconInput
    )

    publish:
    recon_files = val_recon.map { it -> it.recon_files }
}

output {
    recon_files {
    }
}
