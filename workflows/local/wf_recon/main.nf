#!/usr/bin/env nextflow

nextflow.enable.strict = true
nextflow.enable.types = true

include { RECON; ReconMeta } from '../../../modules/local/recon'

record WfReconInput {
    meta: ReconMeta
    recon_count_and_knn_files: List<Path>
}

record WfReconOutput {
    meta: ReconMeta
    recon_files: List<Path>
}

workflow WF_RECON {
    take:
    input: WfReconInput

    main:
    def val_recon = RECON(input)

    // TODO: Email and copy to gcloud the summary.pdf

    val_wf_recon_output = val_recon.map { it -> it as WfReconOutput }

    emit:
    val_wf_recon_output
}
