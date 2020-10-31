from config.ScibConfig import *

#configfile: "config.yaml"
cfg = ParsedConfig(config)
wildcard_constraints:
    hvg = "hvg|full_feature"

include: "scripts/integration/Snakefile"
#include: "scripts/metrics/Snakefile"

rule all:
    input:
        cfg.get_filename_pattern("metrics", "final"),
        cfg.get_filename_pattern("embeddings", "final")

# ------------------------------------------------------------------------------
# Compute metrics
# ------------------------------------------------------------------------------

rule metrics_unintegrated:
    input:        cfg.get_all_file_patterns("metrics_unintegrated")
    message:        "Collect all unintegrated metrics"

rule metrics_integrated:
    input: cfg.get_all_file_patterns("metrics")
    message: "Collect all integrated metrics"

all_metrics = rules.metrics_integrated.input
if cfg.unintegrated_m:
    all_metrics.extend(rules.metrics_unintegrated.input)

rule metrics:
    input:
        tables = all_metrics,
        script = "scripts/merge_metrics.py"
    output:
        cfg.get_filename_pattern("metrics", "final")
    message: "Merge all metrics"
    params:
        cmd = f"conda run -n {cfg.py_env} python"
    shell: "{params.cmd} {input.script} -i {input.tables} -o {output} --root {cfg.ROOT}"

def get_integrated_for_metrics(wildcards):
    if wildcards.method == "unintegrated":
        pattern = str(rules.integration_prepare.output)
        file = os.path.splitext(pattern)[0]
        return f"{file}.h5ad"
    elif cfg.get_from_method(wildcards.method, "R"):
        return cfg.get_filename_pattern("integration", "single", "rds_to_h5ad")
    else:
        return cfg.get_filename_pattern("integration", "single", "h5ad")

rule metrics_single:
    input:
        u      = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="file"),
        i      = get_integrated_for_metrics,
        script = "scripts/metrics.py"
    output: cfg.get_filename_pattern("metrics", "single")
    message:
        """
        Metrics {wildcards}
        output: {output}
        """
    params:
        batch_key = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="batch_key"),
        label_key = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="label_key"),
        organism  = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="organism"),
        assay     = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="assay"),
        hvgs      = lambda wildcards: cfg.get_feature_selection(wildcards.hvg),
        cmd       = f"conda run -n {cfg.py_env} python"
    shell:
        """
        {params.cmd} {input.script} -u {input.u} -i {input.i} -o {output} -m {wildcards.method} \
        -b {params.batch_key} -l {params.label_key} --type {wildcards.o_type} \
        --hvgs {params.hvgs} --organism {params.organism} --assay {params.assay} -v
        """

# ------------------------------------------------------------------------------
# Save embeddings
# ------------------------------------------------------------------------------

rule embeddings_unintegrated:
    input:
        cfg.get_all_file_patterns("embeddings_unintegrated")
    message:
        "Collect all unintegrated embeddings"

rule embeddings_integrated:
    input: cfg.get_all_file_patterns("embeddings")
    message: "Collect all integrated embeddings"

all_embeddings = rules.embeddings_integrated.input
if cfg.unintegrated_m:
    all_embeddings.extend(rules.embeddings_unintegrated.input)

rule embeddings:
    input:
        csvs = all_embeddings
    output:
        cfg.get_filename_pattern("embeddings", "final")
    message:
        "Completed all embeddings"
    shell:
     """
     echo '{input.csvs}' | tr " " "\n" > {output}
     """

rule embeddings_single:
    input:
        adata  = get_integrated_for_metrics,
        script = "scripts/save_embeddings.py"
    output:
        coords = cfg.get_filename_pattern("embeddings", "single"),
        batch_png = cfg.get_filename_pattern("embeddings", "single").replace(".csv", "_batch.png"),
        labels_png = cfg.get_filename_pattern("embeddings", "single").replace(".csv", "_labels.png")
    message:
        """
        SAVE EMBEDDING
        Scenario: {wildcards.scenario} {wildcards.scaling} {wildcards.hvg}
        Method: {wildcards.method} {wildcards.o_type}
        Input: {input.adata}
        Output: {output}
        """
    params:
        batch_key = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="batch_key"),
        label_key = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="label_key"),
        cmd       = f"conda run -n {cfg.py_env} python"
    shell:
        """
        {params.cmd} {input.script} --input {input.adata} --outfile {output.coords} \
            --method {wildcards.method} --batch_key {params.batch_key} \
            --label_key {params.label_key} --result {wildcards.o_type}
        """

# ------------------------------------------------------------------------------
# Cell cycle score sanity check
# ------------------------------------------------------------------------------

rule cc_variation:
    input:
        tables = cfg.get_all_file_patterns("cc_variance", output_types=["full", "embed"]),
        script = "scripts/merge_cc_variance.py"
    output: cfg.get_filename_pattern("cc_variance", "final")
    params:
        cmd = f"conda run -n {cfg.py_env} python"
    shell: "{params.cmd} {input.script} -i {input.tables} -o {output} --root {cfg.ROOT}"

rule cc_single:
    input:
        u      = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="file"),
        i      = cfg.get_filename_pattern("integration", "single"),
        script = "scripts/cell_cycle_variance.py"
    output: cfg.get_filename_pattern("cc_variance", "single")
    params:
        batch_key = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="batch_key"),
        organism  = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="organism"),
        assay     = lambda wildcards: cfg.get_from_scenario(wildcards.scenario, key="assay"),
        hvgs      = lambda wildcards: cfg.get_feature_selection(wildcards.hvg),
        cmd       = f"conda run -n {cfg.py_env} python"
    shell:
        """
        {params.cmd} {input.script} -u {input.u} -i {input.i} -o {output} \
        -b {params.batch_key} --assay {params.assay} --type {wildcards.o_type} \
        --hvgs {params.hvgs} --organism {params.organism}
        """

# ------------------------------------------------------------------------------
# Merge benchmark files
#
# Run this after the main pipeline using:
# snakemake --configfile config.yaml --cores 1 benchmarks
# ------------------------------------------------------------------------------

rule benchmarks:
    input:
        script = "scripts/merge_benchmarks.py"
    output:
        cfg.get_filename_pattern("benchmarks", "final")
    message: "Merge all benchmarks"
    params:
        cmd = f"conda run -n {cfg.py_env} python"
    shell: "{params.cmd} {input.script} -o {output} --root {cfg.ROOT}"
