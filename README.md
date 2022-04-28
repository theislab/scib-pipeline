# Pipeline for benchmarking atlas-level single-cell integration

This repository contains the snakemake pipeline for our benchmarking study for data integration tools.
In this study, we benchmark 16 methods ([see here](##tools)) with 4 combinations of preprocessing steps leading to 68 
methods combinations on 85 batches of gene expression and chromatin accessibility data.
The pipeline uses the [`scib`](https://github.com/theislab/scib.git) package and allows for reproducible and automated
analysis of the different steps and combinations of preprocesssing and integration methods.

![Workflow](./figure.png)

## Resources

- On our [website](https://theislab.github.io/scib-reproducibility) we visualise the results of the study.

- The scib package that is used in this pipeline can be found [here](https://github.com/theislab/scib).

- For reproducibility and visualisation we have a dedicated repository: [scib-reproducibility](https://github.com/theislab/scib-reproducibility).

- The data used in the study on  [figshare](https://figshare.com/articles/dataset/Benchmarking_atlas-level_data_integration_in_single-cell_genomics_-_integration_task_datasets_Immune_and_pancreas_/12420968)

### Please cite:

_**Benchmarking atlas-level data integration in single-cell genomics.**  
MD Luecken, M Büttner, K Chaichoompu, A Danese, M Interlandi, MF Mueller, DC Strobl, L Zappia, M Dugas, M Colomé-Tatché, FJ Theis
bioRxiv 2020.05.22.111161; doi: https://doi.org/10.1101/2020.05.22.111161 _

## Installation

To reproduce the results from this study, two separate conda environments are needed for python and R operations.
Please make sure you have [`conda`](https://conda.io/projects/conda) installed on your system to be
able to use the pipeline.
We also recommend installing ['mamba'](https://mamba.readthedocs.io) for shorter installation times and smaller memory
overhead.

The installation is automated by an installation script that install the correct python and R environments based on the
R version you want to use.
The pipeline currently supports R 3.6 and R 4.0, and we generally recommend using the latest R version.
Call the script as follows e.g. for R 4.0

```commandline
bash envs/create_conda_environments.sh -r 4.0
```

Check the script's help output in order to get the full list of arguments it uses.

```commandline
bash envs/create_conda_environments.sh -h 
```

Once installation is successful, you will have the python environment `scib-pipeline-<R version>` and the R environment
`scib-<R version>` that you must specify in the config file (see [click on this link](#setup-configuration-file)).

| R version | Environment name     | YAML file location            |
|-----------|----------------------|-------------------------------|
| 4.0       | `scib-pipeline-R4.0` | `envs/scib-pipeline-R4.0.yml` |
| 3.6       | `scib-pipeline-R3.6` | `envs/scib-pipeline-R3.6.yml` |


For a more detailed description of the environment files and how to install the different environments manually, please
refer to the README in the `envs/`.


## Running the Pipeline

This repository contains a [snakemake](https://snakemake.readthedocs.io/en/stable/) pipeline to run integration methods
and metrics reproducibly for different data scenarios preprocessing setups.

### Generate Test data

A script in `data/` can be used to generate test data.
This is useful, in order to ensure that the installation was successful before moving on to a larger dataset.
More information on how to use the data generation script can be found in `data/README.md`.

### Setup Configuration File

The parameters and input files are specified in config files, that can be found in `configs/`.
In the `DATA_SCENARIOS` section you can define the input data per scenario.
The main input per scenario is a preprocessed `.h5ad` file of an anndata with batch and cell type annotations.

TODO: explain different entries

### Pipeline Commands

To call the pipeline on the test data

```commandline
snakemake --configfile configs/test_data.yaml -n
```

This gives you an overview of the jobs that will be run.
In order to execute these jobs, call

```commandline
snakemake --configfile configs/test_data.yaml --cores N_CORES
```

where `N_CORES` defines the number of threads to use.

More snakemake commands can be found in the [documentation](snakemake.readthedocs.io/).

### Visualise the Workflow

A dependency graph of the workflow can be created anytime and is useful to gain a general understanding of the workflow.
Snakemake can create a `graphviz` representation of the rules, which can be piped into an image file.

```shell
snakemake --configfile configs/test_data-R3.6.yaml --rulegraph | dot -Tpng -Grankdir=TB > dependency.png
```

![Snakemake workflow](./dependency.png)

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
