# Pipeline for benchmarking atlas-level single-cell integration

This repository contains the snakemake pipeline for our benchmarking study for data integration tools.
In this study, we benchmark 16 methods ([see here](##tools)) with 4 combinations of preprocessing steps leading to 68 
methods combinations on 85 batches of gene expression and chromatin accessibility data.
The pipeline uses the [`scIB`](https://github.com/theislab/scib.git) package and allows for reproducible and automated
analysis of the different steps and combinations of preprocesssing and integration methods.

![Workflow](./figure.png)

## Resources

- On our [website](https://theislab.github.io/scib-reproducibility) we visualise the results of the study.

- The scib package that is used in this pipeline can be found [here](https://github.com/theislab/scib).

- For reproducibility and visualisation we have a dedicated repository: [scib-reproducibility](https://github.com/theislab/scib-reproducibility).

### Please cite:

_**Benchmarking atlas-level data integration in single-cell genomics.**  
MD Luecken, M Büttner, K Chaichoompu, A Danese, M Interlandi, MF Mueller, DC Strobl, L Zappia, M Dugas, M Colomé-Tatché, FJ Theis
bioRxiv 2020.05.22.111161; doi: https://doi.org/10.1101/2020.05.22.111161 _

## Installation

To reproduce the results from this study, three different conda environments are needed.
There are different environments for the python integration methods, the R integration methods and
the conversion of R data types to anndata objects.

For the installation of conda, follow [these](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) instructions
or use your system's package manager. The environments have only been tested on linux operating systems
although it should be possible to run the pipeline using Mac OS.

To create the conda environments use the `.yml` files in the `envs` directory.
To install the envs, use

```console
conda env create -f FILENAME.yml
```

> Note: Instead of `conda` you can use `mamba` to speed up installation times

### Setting Environment Parameters

Some parameters need to be added manually to the conda environment in order for packages to work correctly.
For example, all environments using R need `LD_LIBRARY_PATH` set to the conda R library path.
If that variable is not set, `rpy2` might reference the library path of a different R installation that might be on your system.

Environment variables are provided in `env_vars_activate.sh` and `env_vars_deactivate.sh` and should be copied to the designated locations of each conda environment.
Make sure to determine `$CONDA_PREFIX` in the activated environment first, then deactivate the environment before copying the files to prevent unwanted effects.

e.g. for scIB-python:

```console
conda activate scIB-python
echo $CONDA_PREFIX  # referred to as <conda_prefix>
conda deactivate

# copy activate variables
cp envs/env_vars_activate.sh <conda_prefix>/etc/conda/activate.d/env_vars.sh
# copy deactivate variables
cp envs/env_vars_deactivate.sh <conda_prefix>/etc/conda/deactivate.d/env_vars.sh
```

If necessary, create any missing directories manually.
In case some lines in the environment scripts cause problems, you can edit the files to trouble-shoot.

These operations are also automated in the `envs/set_vars.sh` script, which you can call via

```console
. envs/set_vars.sh <env-name>
```

### Python environments

There are multiple different environments for the python dependencies:

| YAML file location           | Environment name    | Description                                                                                           |
| ---------------------------- | ------------------- | ----------------------------------------------------------------------------------------------------- |
| `envs/scib-pipeline.yml`     | `scib-pipeline`     | Base environment for calling the pipeline, running python integration methods and computing metrics   |
| `envs/scIB-python-paper.yml` | `scIB-python-paper` | Environment used for the results in the [publication](doi: https://doi.org/10.1101/2020.05.22.111161) |

The `scib-pipeline` environment is the one that the user activates before calling the pipeline.
It needs to be specified under the `py_env` key in the config files under `configs/` so that the pipelien will use it for running python methods. Alternatively, you can specify `scIB-python-paper` as the `py_env`, so that the dependencies of the paper are used instead for integration runs. 
Furthermore, `scib-pipeline` python environments require the R package [`kBET`](https://github.com/theislab/kBET) to be installed manually. This also requires that environment variables are set as described above, so that R packages are correctly installed and located. Once environment variables have been set, you can install `kBET`:

```console
conda activate scib-pipeline
Rscript -e "devtools::install_github('theislab/kBET')"
```

### R environments

| YAML file location            | Environment name     | Description                                                                                           |
| ----------------------------- | -------------------- | ----------------------------------------------------------------------------------------------------- |
| `envs/scIB-R-integration.yml` | `scIB-R-integration` | Environment used for the results in the [publication](doi: https://doi.org/10.1101/2020.05.22.111161) |
| `envs/scib-R.yml`             | `scib-R`             | Updated environment with R dependencies                                                               |

In the R environments, some R packages need to be installed manually.
Activate the environment and install the packages all the R dependencies in R directly or use the script `install_R_methods.R`.

```commandline
conda activate <r environment>
Rscript envs/install_R_methods.R
```

For the installation of`Conos`, please see [here](https://github.com/hms-dbmi/conos).

We used these conda versions of the R integration methods in our study:

```
harmony_1.0
Seurat_3.2.0
conos_1.3.0
liger_0.5.0
batchelor_1.4.0
```

## Running the Pipeline

This repository contains a [snakemake](https://snakemake.readthedocs.io/en/stable/) pipeline to run integration methods and metrics reproducibly for different data scenarios preprocessing setups.

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
snakemake --configfile configs/test_data.yaml --rulegraph | dot -Tpng -Grankdir=TB > dependency.png
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
