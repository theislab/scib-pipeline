# Create Test Data
In order to test whether the pipeline is running, here is a script that creates a small dataset with normalised and
log-transformed counts.

Call the `generate_data.py` script
```
python generate_data.py
```
which will produce the `adata_norm.h5ad` file in this directory of the script. 
Use flag `-f` to overwrite an existing files.
