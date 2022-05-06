# Conda environments

This README describes the manual installation steps for the different environments and gives a more detailed overview
of the different environment files.
This is useful for troubleshooting when the installation script does not work.

All environments need to be generated according to the following steps:

1. [Create the conda environment](#create-conda-environments)
2. [Set environment variables](#setting-environment-variables)
3. [Install any extra packages through `R`](#install-additional-packages-through-r)

For R environments, some dependencies need to be installed after the environment has been created. However, it is
important to set environment variables for the conda environments first, to guarantee that the correct R version
installs packages into the correct directories. All necessary steps are mentioned below.

## 1. Create Conda environments

For the installation of conda, follow [these](https://conda.io/projects/conda/en/latest/user-guide/install/index.html).
The environments have only been tested on linux operating systems,
although it should be possible to run the pipeline using Mac OS.

The conda environments are defined in `.yml` files.
In order for the pipeline to work out of the box, you need a python and an R environment matched by R version.
The different environments are explained below and the general command to install them is:

```commandline
conda env create -f ENVIRONMENT.yml
```

> **Note**: Instead of `conda` you can use `mamba` to speed up installation

### Python environments

There are multiple different environments for the python dependencies:

| YAML file location       | Environment name     | Description                                                             |
|--------------------------|----------------------|-------------------------------------------------------------------------|
| `scib-pipeline-R4.0.yml` | `scib-pipeline-R4.0` | Base environment for calling the pipeline using R 4.0 and python >= 3.7 |
| `scib-pipeline-R3.6.yml` | `scib-pipeline-R3.6` | Base environment for calling the pipeline using R 3.6 and python >= 3.7 |
| `scIB-python-paper.yml`  | `scIB-python-paper`  | Environment used for the results in the [study][publication]            |

The `scib-pipeline` environment is the one that the user activates before calling the pipeline. It needs to be specified
under the `py_env` key in the config files under `configs/` so that the pipeline will use it for running python methods.
Alternatively, you can specify `scIB-python-paper` as the `py_env` to recreate the environment used in the paper to
reproduce the results.

> **Note**: `scIB-python-paper` is deprecated and only included for reproducibility purposes and is not updated with
> changes to the pipeline code.
> We don't recommend using it, as old dependencies tend to break after newer packages are available.

### R environments

| YAML file location       | Environment name     | R dependency file        | Description                                                  |
|--------------------------|----------------------|--------------------------|--------------------------------------------------------------|
| `scib-R4.0.yml`          | `scib-R4.0`          | 'dependencies-R4.0.tsv'  | R environment using R 4.0                                    |
| `scib-R3.6.yml`          | `scib-R3.6`          | 'dependencies-R3.6.tsv'  | R environment using R 3.6                                    |
| `scIB-R-integration.yml` | `scIB-R-integration` | 'r36_dependencies.tsv'   | Environment used for the results in the [study][publication] |

Depending on the R environment used, some R packages must be additionally installed in R instead of conda. For
convenience, we provide the `install_R_methods.R` scripts that installs the necessary dependencies through R
directly. Don't forget to set the environment variables before installing anything through R. e.g. for `scib-R`:

> **Note**: `scIB-python-paper` is deprecated and only included for reproducibility purposes and is not updated with
> changes to the pipeline code.
> We don't recommend using it, as old dependencies tend to break after newer packages are available.

## 2. Setting Environment Variables

We experience difficulties working with `rpy2` and R installations when working on machines that already have a system
installation of R.
In order to make sure that R libraries are correctly isolated to their respective environments, we provide environment
variables that should be set during environment activation and reset during deactivation.
You must first determine path of your environment, either by activating and viewing the `$CONDA_PREFIX`, or by listing
all conda environments.

```shell
# check CONDA_PREFIX variable directly
conda activate scib-pipeline-R4.0
echo $CONDA_PREFIX
conda deactivate

# list conda enviromnents
conda env list
```

We provide the following script, which you should call for each environment that uses R.
Make sure to deactivate your environment before setting any environment variables, to prevent unwanted effects.

```shell
bash set_vars.sh <path to conda env>
```

After the script has successfully finished, you should be ready to use your new environment.

### Alternative: Set environment variables manually

If you want to set these and potentially other variables manually, proceed as follows.
Environment variables are provided in `env_vars_activate.sh` and `env_vars_deactivate.sh` and should be copied to the
designated locations of each conda environment.

e.g. for scib-pipeline-R4.0:

```shell
conda activate scib-pipeline-R4.0
conda_prefix=$CONDA_PREFIX 
conda deactivate

# copy activate variables
cp env_vars_activate.sh $conda_prefix/etc/conda/activate.d/env_vars.sh
# copy deactivate variables
cp env_vars_deactivate.sh $conda_prefix/etc/conda/deactivate.d/env_vars.sh
```

If necessary, create any missing directories manually.
In case some lines in the environment scripts cause problems, you can edit the environment variable files to
trouble-shoot.

## 3. Install additional packages through R

Some R packages are not available through conda and must be installed through R.
This applies both to the python and R environments.
Please make sure that the environment variables are set correctly as described in the
[previous step](#2-setting-environment-variables).

### Install `kBET` for python environments

The kBET metric is implemented in R and must be installed from [source code](https://github.com/theislab/kBET).
In your python environment (e.g. here `scib-pipeline-R4.0`), install `kBET` as follows:

```shell
conda activate scib-pipeline-R4.0
Rscript -e "devtools::install_github('theislab/kBET')"
```

> **Note**: `devtools` should already be installed through conda

### Install R integration methods in R environment

Activate your R environment (e.g. here `scib-R4.0`) and use the `install_R_methods.R` script with the corresponding R
dependency file for your environment (see [table](#r-environments)).

```shell
conda activate scib-R4.0
Rscript install_R_methods.R -d dependencies-R4.0.tsv
```

We used these conda versions of the R integration methods in our study:

```commandline
harmony_1.0
seurat_3.2.0
conos_1.3.0
liger_0.5.0
batchelor_1.4.0
```

[publication]: https://doi.org/10.1038/s41592-021-01336-8