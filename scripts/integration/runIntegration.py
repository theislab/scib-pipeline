#!/usr/bin/env python
# coding: utf-8

import scanpy as sc
import scib
import warnings

warnings.filterwarnings('ignore')

METHODS = {
    'scanorama': scib.integration.scanorama,
    'trvae': scib.integration.trvae,
    'trvaep': scib.integration.trvaep,
    'scgen': scib.integration.scgen,
    'mnn': scib.integration.mnn,
    'bbknn': scib.integration.bbknn,
    'scvi': scib.integration.scvi,
    'scanvi': scib.integration.scanvi,
    'combat': scib.integration.combat,
    'saucie': scib.integration.saucie,
    'desc': scib.integration.desc
}


def runIntegration(inPath, outPath, method, hvg, batch, celltype=None):
    """
    params:
        method: name of method
        batch: name of `adata.obs` column of the batch
        max_genes_hvg: maximum number of HVG
    """

    adata = sc.read(inPath)

    if celltype is not None:
        integrated = method(adata, batch, celltype)
    else:
        integrated = method(adata, batch)

    sc.write(outPath, integrated)


def get_method(method_name):
    if method_name not in METHODS:
        raise ValueError(
            f'Method "{method_name}" does not exist. Please use one of '
            f'the following:\n{list(METHODS.keys())}'
        )
    return METHODS[method_name]


if 'snakemake' in dir():
    runIntegration(
        inPath=snakemake.input.adata,
        outPath=snakemake.output[0],
        method=get_method(snakemake.params.method),
        hvg=int(snakemake.params.hvgs),
        batch=snakemake.params.batch_key,
        celltype=snakemake.params.cell_type,
    )


elif __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Run the integration methods')

    parser.add_argument('-m', '--method', required=True)
    parser.add_argument('-i', '--input_file', required=True)
    parser.add_argument('-o', '--output_file', required=True)
    parser.add_argument('-b', '--batch', required=True, help='Batch variable')
    parser.add_argument('-v', '--hvgs', help='Number of highly variable genes', default=2000)
    parser.add_argument("-c", '--celltype', help='Cell type variable', default=None)

    args = parser.parse_args()
    file = args.input_file
    out = args.output_file
    batch = args.batch
    hvg = int(args.hvgs)
    celltype = args.celltype
    method = args.method
    run = get_method(method)
    runIntegration(file, out, run, hvg, batch, celltype)
