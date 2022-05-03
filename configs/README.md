# Config files

This directory contains different configuration files using test data that can be created in the `data/` directory of
the repository.

Below is an overview of all the config files we provide.

| Test data config YAML file | Description                                             | Environments (`py_env`, `r_env`)          |
|----------------------------|---------------------------------------------------------|-------------------------------------------|
| `test_data-R4.0.yml`       | Test data using R 4.0 environments on all methods       | `scib-pipeline-R4.0`, `scib-R4.0`         |
| `test_data-R4.0_small.yml` | Test data using R 4.0 environments on subset of methods | `scib-pipeline-R4.0`, `scib-R4.0`         |
| `test_data-R3.6.yml`       | Test data using R 3.6 environments on all methods       | `scib-pipeline-R3.6`, `scib-R3.6`         |
| `test_data-R3.6_small.yml` | Test data using R 3.6 environments on subset of methods | `scib-pipeline-R3.6`, `scib-R3.6`         |
| `reproduce_paper.yml`      | Config used for our study                               | `scIB-python-paper`, `scIB-R-integration` |


## Configuration specifications

> TODO: more verbose explanation of entries

The configuration files contain keys for methods, datasets as well as parameters for feature selection and scaling.
Additionally, the config files specify the python and R environments that it should use.

A config file is structured as follows:

```yaml
ROOT: data # root directory
py_env : scib-pipeline-R3.6  # name of Python
r_env : scib-R3.6 # name of R environment

unintegrated_metrics: false  # whether to run metrics on the unintegrated dataset

FEATURE_SELECTION:
# any setup of feature selection setup name (used for directories) and number features to select
  hvg: 2000
  full_feature: 0  # use 0 full feature data (no feature selection)

SCALING:
# scaling setup 
# any combination of 'unscaled', 'scaled' or both
  - unscaled
  - scaled

METHODS:
# Possible keys are:
#   Python methods: bbknn, combat, desc, mnn, saucie, scanorama, scanvi, scgen, scvi, trvae, trvaep
#   R methods: conos, fastmnn, harmony, liger, seurat, seuratpca
  bbknn:
    output_type: knn  # single entry or list of output types that the method provides. Entries: [knn, embed, full]
  scanorama:
    output_type:
      - embed
      - full
  scanvi:
    output_type: embed
    no_scale: true  # specific to methods that don't work with scaled data. Scaling setups will 
    use_celltype: true  # specific to methods that require cell type label as input
  seurat:
    R: true  # specify whether the method has to be run in R, otherwise assume there is a scib function for the method
    output_type: full

DATA_SCENARIOS:
# All keys of a dataset are mandatory
  dataset_1: # name by which to identify the dataset. Used as directory name and in the final metrics file 
    batch_key: batch  # name of key on anndata.obs that annotates the batches
    label_key: celltype  # name of key on anndata.obs that annotates the cell identity labels
    organism: mouse  # organism for cell cycle gene scoring
    assay: expression  # one of 'expression' and 'atac'
    file: data/adata_norm.h5ad  # file path to normalised and log-transformed input object
  dataset_2:
    ...
```
