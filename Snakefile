from ScibConfig import *

#configfile: "config.yaml"
cfg = ParsedConfig(config)
wildcard_constraints:
    hvg="hvg|full_feature",
    scaling="scaled|unscaled",
    method="[^/]+"


module preprocessing:
    snakefile: "scripts/preprocessing/Snakefile"
    config: config


module integration:
    snakefile: "scripts/integration/Snakefile"
    config: config

module metrics:
    snakefile: "scripts/metrics/Snakefile"
    config: config

module visualization:
    snakefile: "scripts/visualization/Snakefile"
    config: config

use rule * from preprocessing as preprocessing_ *
use rule * from integration as integration_ *
use rule * from metrics as metrics_ *
use rule * from visualization as visualization_ *

rule all:
    input:
        rules.integration_all.input,
        rules.metrics_all.output,
        rules.visualization_all.output

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
