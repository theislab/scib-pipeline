#!/usr/bin/env python
# coding: utf-8

import scanpy as sc
import scib
import argparse
import os
import sys
import warnings

warnings.filterwarnings('ignore')

RESULT_TYPES = [
    "full",  # reconstructed expression data
    "embed",  # embedded/latent space
    "knn"  # corrected neighbourhood graph
]

def save_embeddings(infile, outfile, method, result, batch_key, label_key, labels_png=None, batches_png=None):
    """Save 2D embeddings and corresponding plots."""
    setup = f'{method}_{result}'

    outdir = os.path.dirname(outfile)
    if labels_png is None:
        labels_png = os.path.join(outdir, f'{setup}_labels.png')
    if batches_png is None:
        batches_png = os.path.join(outdir, f'{setup}_batch.png')

    if os.stat(infile).st_size == 0:
        print(f'{infile} is empty, empty output files will be created')

        # Create empty output files
        for file in [labels_png, batches_png, outfile]:
            print(f'Creating empty {file}')
            open(file, "w").close()

        # End script
        sys.exit()

    adata = sc.read_h5ad(infile)

    print('Preparing dataset...')
    if result == 'embed':
        scib.pp.reduce_data(
            adata,
            n_top_genes=None,
            neighbors=True,
            use_rep='X_emb',
            pca=False,
            umap=False
        )
    elif result == 'full':
        sc.pp.filter_genes(adata, min_cells=1)
        scib.pp.reduce_data(
            adata,
            n_top_genes=2000,
            neighbors=True,
            use_rep='X_pca',
            pca=True,
            umap=False
        )

    # Calculate embedding
    if method.startswith('conos'):
        print('Calculating graph embedding...')
        sc.tl.draw_graph(adata, key_added_ext='graph')
        basis = 'draw_graph_graph'
        label = 'Graph'
    else:
        print('Calculating UMAP...')
        sc.tl.umap(adata)
        basis = 'umap'
        label = 'UMAP'

    # Save embedding plots
    os.makedirs(outdir, exist_ok=True)
    print(f'Saving embedding plot for labels "{label_key}"...')
    fig = sc.pl.embedding(adata, basis=basis, color=label_key, return_fig=True)
    fig.set_size_inches(10, 8)
    fig.savefig(labels_png, bbox_inches='tight')
    print(f'Saving embedding plot for batches "{batch_key}"...')
    fig = sc.pl.embedding(adata, basis=basis, color=batch_key, return_fig=True)
    fig.set_size_inches(10, 8)
    fig.savefig(batches_png, bbox_inches='tight')

    # Save embedding coordinates
    print('Saving embedding coordinates...')
    adata.obs[label + '1'] = adata.obsm['X_' + basis][:, 0]
    adata.obs[label + '2'] = adata.obsm['X_' + basis][:, 1]
    coords = adata.obs[[label_key, batch_key, label + '1', label + '2']]

    coords.to_csv(os.path.join(outfile), index_label='CellID')


if 'snakemake' in dir():
    save_embeddings(
        infile=snakemake.input.adata,
        outfile=snakemake.output.coords,
        method=snakemake.params.method,
        result=snakemake.params.result,
        batch_key=snakemake.params.batch_key,
        label_key=snakemake.params.label_key,
        labels_png=snakemake.output.label_png,
        batches_png=snakemake.output.batch_png,
    )

elif __name__ == '__main__':
    """
    Save embeddings for all scenarios, methods and settings
    """

    parser = argparse.ArgumentParser(description='Save embeddings')

    parser.add_argument('-i', '--input', required=True)
    parser.add_argument('-o', '--outfile', required=True,
                        help='Output coordinates CSV file')
    parser.add_argument('-m', '--method', required=True, help='Name of method')
    parser.add_argument('-r', '--result', required=True, choices=RESULT_TYPES,
                        help='Type of result: full, embed, knn')
    parser.add_argument('-b', '--batch_key', required=True, help='Key of batch')
    parser.add_argument('-l', '--label_key', required=True,
                        help='Key of annotated labels e.g. "cell_type"')

    args = parser.parse_args()
    save_embeddings(
        infile=args.input,
        outfile=args.outfile,
        method=args.method,
        result=args.result,
        batch_key=args.batch_key,
        label_key=args.label_key,
    )
