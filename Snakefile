from ScibConfig import *

#configfile: "config.yaml"
cfg = ParsedConfig(config)
wildcard_constraints:
    hvg = "hvg|full_feature"

include: "scripts/preprocessing/Snakefile"
include: "scripts/integration/Snakefile"
include: "scripts/metrics/Snakefile"
include: "scripts/visualization/Snakefile"

rule all:
    input:
        rules.integration.input,
        rules.metrics.output,
        rules.embeddings.output

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
        cfg.ROOT / "benchmarks.csv"
    message: "Merge all benchmarks"
    params:
        cmd = f"conda run -n {cfg.py_env} python"
    shell: "{params.cmd} {input.script} -o {output} --root {cfg.ROOT}"
