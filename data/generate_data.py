import scanpy as sc
import numpy as np
import scIB


def get_adata_rand_batch(pca=False, n_top_genes=None, neighbors=False):
    adata = sc.datasets.paul15()
    adata.obs['celltype'] = adata.obs['paul15_clusters']
    np.random.seed(42)
    adata.obs['batch'] = np.random.randint(1, 5, adata.n_obs)
    adata.obs['batch'] = adata.obs['batch'].astype(str)
    adata.obs['batch'] = adata.obs['batch'].astype("category")
    adata.layers['counts'] = adata.X
    scIB.preprocessing.reduce_data(
        adata,
        pca=pca,
        n_top_genes=n_top_genes,
        umap=False,
        neighbors=neighbors
    )
    return adata


def get_adata_pbmc():
    #adata_ref = sc.datasets.pbmc3k_processed()
    # quick fix for broken dataset paths, should be removed with scanpy>=1.6.0
    adata_ref = sc.read(
        "pbmc3k_processed.h5ad",
        backup_url="https://raw.githubusercontent.com/chanzuckerberg/cellxgene/main/example-dataset/pbmc3k.h5ad"
    )
    adata = sc.datasets.pbmc68k_reduced()

    var_names = adata_ref.var_names.intersection(adata.var_names)
    adata_ref = adata_ref[:, var_names]
    adata = adata[:, var_names]

    sc.pp.pca(adata_ref)
    sc.pp.neighbors(adata_ref)
    sc.tl.umap(adata_ref)

    # merge cell type labels
    sc.tl.ingest(adata, adata_ref, obs='louvain')
    adata_concat = adata_ref.concatenate(adata, batch_categories=['ref', 'new'])
    adata_concat.obs.louvain = adata_concat.obs.louvain.astype('category')
    # fix category ordering
    adata_concat.obs.louvain.cat.reorder_categories(adata_ref.obs.louvain.cat.categories, inplace=True)
    adata_concat.obs['celltype'] = adata_concat.obs['louvain']

    del adata_concat.obs['louvain']
    del adata_concat.uns
    del adata_concat.obsm
    del adata_concat.varm

    return adata_concat


if __name__ == '__main__':
    import argparse
    from pathlib import Path

    parser = argparse.ArgumentParser(description='Generate test dataset')
    parser.add_argument('-f', '--force', action='store_true')
    args = parser.parse_args()

    filepath = Path(__file__).parent / 'adata_norm.h5ad'

    if not filepath.exists() or args.force:
        adata = get_adata_rand_batch()
        adata.write(filepath)