#!/usr/bin/env nextflow

nextflow.enable.strict = true
nextflow.enable.types = true

record ReconResourcesInput {
    recon_count_and_knn_dir: Path?
    recon_dir: Path?
    bcl_name: String?
    recon_name: String?
}

record ReconResourcesOutput {
    bcl_name: String
    recon_name: String
    recon_count_and_knn_files: List<Path>
}

def calcReconResources(input: ReconResourcesInput) -> ReconResourcesOutput {
    if (!input.recon_count_and_knn_dir && !input.recon_dir) {
        error("Either 'recon_count_and_knn_dir' or 'recon_dir' must be specified.")
    }
    if (input.recon_count_and_knn_dir && input.recon_dir) {
        error("Cannot use both 'recon_count_and_knn_dir' and 'recon_dir' as they are mutually exclusive. Only one should be specified.")
    }

    if (input.recon_dir) {
        return record(
            bcl_name: input.bcl_name,
            recon_name: input.recon_name,
            recon_count_and_knn_files: (input.recon_dir / input.bcl_name / input.recon_name).listDirectory()
        )
    } else {
        return record(
            bcl_name: input.bcl_name ?: input.recon_count_and_knn_dir.parent.baseName,
            recon_name: input.recon_name ?: input.recon_count_and_knn_dir.baseName,
            recon_count_and_knn_files: input.recon_count_and_knn_dir.listDirectory()
        )
    }
}
