# Pipeline for benchmarking atlas-level single-cell integration

This repository contains the snakemake pipeline for the benchmarking study for data integration tools.
In this study, we benchmark 16 methods ([see here](##tools)) with 4 combinations of preprocessing steps leading to 68 
methods combinations on 85 batches of gene expression and chromatin accessibility data.
The pipeline uses the [`scIB`](https://github.com/theislab/scib.git) package and allows for reproducible and automated
analysis of the different steps and combinations of preprocesssing and integration methods.

![Workflow](./figure.png)

## Installation
To reproduce the results from this study, three different conda environments are needed.
There are different environments for the python integration methods, the R integration methods and
the conversion of R data types to anndata objects.

For the installation of conda, follow [these](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) instructions
or use your system's package manager. The environments have only been tested on linux operating systems
although it should be possible to run the pipeline using Mac OS.

To create the conda environments use the `.yml` files in the `envs` directory.
To install the envs, use
```bash
conda env create -f FILENAME.yml
``` 
To set the correct paths so that R the correct R libraries can be found, copy `env_vars_activate.sh` to `etc/conda/activate.d/`
and `env_vars_deactivate.sh` to `etc/conda/deactivate.d/` to every environment.
In the `scIB-R-integration` environment, R packages need to be installed manually.
Activate the environment and install the packages `scran`, `Seurat` and `Conos` in R. `Conos` needs to be installed using R devtools.
See [here](https://github.com/hms-dbmi/conos).


## Running the integration methods
This package allows to run a multitude of single cell data integration methods in both `R` and `python`.
We use [Snakemake](https://snakemake.readthedocs.io/en/stable/) to run the pipeline.
The parameters of the run are configured using the `config.yaml` file.
See the `DATA_SCENARIOS` section to change the data used for integration.
The script expects one `.h5ad` file containing all batches per data scenario.

To load the config file run `snakemake --configfile config.yaml`.
Define the number of CPU threads you want to use with `snakemake --cores N_CORES`. To produce an overview of tasks that will be run, use `snakemake -n`.
To run the pipeline, simply run `snakemake`.

## Tools
Tools that are compared include:
- [Scanorama](https://github.com/brianhie/scanorama)
- [scANVI](https://github.com/chenlingantelope/HarmonizationSCANVI)
- [FastMNN](https://bioconductor.org/packages/batchelor/)
- [scGen](https://github.com/theislab/scgen)
- [BBKNN](https://github.com/Teichlab/bbknn)
- [scVI](https://github.com/YosefLab/scVI)
- [Seurat v3 (CCA and RPCA)](https://github.com/satijalab/seurat)
- [Harmony](https://github.com/immunogenomics/harmony)
- [Conos](https://github.com/hms-dbmi/conos) [tutorial](https://htmlpreview.github.io/?https://github.com/satijalab/seurat.wrappers/blob/master/docs/conos.html)
- [Combat](https://scanpy.readthedocs.io/en/stable/api/scanpy.pp.combat.html) [paper](https://academic.oup.com/biostatistics/article/8/1/118/252073)
- [MNN](https://github.com/chriscainx/mnnpy)
- [TrVae](https://github.com/theislab/trvae)
- [DESC](https://github.com/eleozzr/desc)
- [LIGER](https://github.com/MacoskoLab/liger)
- [SAUCIE](https://github.com/KrishnaswamyLab/SAUCIE)