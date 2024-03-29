loadSeuratObject = function(filename) {
	require(Seurat)
	sobj = readRDS(filename)
	return(sobj)
}

saveSeuratObject = function(sobj, path) {
	require(Seurat)
	saveRDS(sobj, file=path)
}

runSeurat = function(data, batch, hvg=2000) {
	  require(Seurat)
	  batch_list = SplitObject(data, split.by = batch)

	  anchors = FindIntegrationAnchors(
	          object.list = batch_list,
	          anchor.features = hvg,
 		  scale = T,
		  l2.norm = T,
		  dims = 1:30,
        	  k.anchor = 5,
        	  k.filter = 200,
        	  k.score = 30,
        	  max.features = 200,
        	  eps = 0)
	  integrated = IntegrateData(
        	   anchorset = anchors,
		   new.assay.name = "integrated",
        	   features = NULL,
        	   features.to.integrate = NULL,
        	   dims = 1:30,
        	   k.weight = 100,
        	   weight.reduction = NULL,
        	   sd.weight = 1,
        	   sample.tree = NULL,
        	   preserve.order = F,
        	   do.cpp = T,
        	   eps = 0,
        	   verbose = T)
	  return(integrated)
}

runSeuratRPCA = function(data, batch, hvg=2000) {
	  require(Seurat)
	  batch_list = SplitObject(data, split.by = batch)

          #features <- SelectIntegrationFeatures(batch_list)
          batch_list <- lapply(X = batch_list, FUN = function(x) {
		  x  <- ScaleData(x, features = hvg)
		  x <- RunPCA(x, features = hvg)
		  return(x)
	  })

	  anchors = FindIntegrationAnchors(
	          object.list = batch_list,
	          anchor.features = hvg,
 		  scale = T,
		  l2.norm = T,
		  dims = 1:30,
        	  k.anchor = 5,
        	  k.filter = 200,
        	  k.score = 30,
		  reduction = "rpca",
        	  max.features = 200,
        	  eps = 0)
	  integrated = IntegrateData(
        	   anchorset = anchors,
		   new.assay.name = "integrated",
        	   features = NULL,
        	   features.to.integrate = NULL,
        	   dims = 1:30,
        	   k.weight = 100,
        	   weight.reduction = NULL,
        	   sd.weight = 1,
        	   sample.tree = NULL,
        	   preserve.order = F,
        	   do.cpp = T,
        	   eps = 0,
        	   verbose = T)
	  return(integrated)
}


func_profiler = function(expr, chunksize=20000, filename='timing.out', prof.interval=0.02) {
	      Rprof(filename, memory.profiling=T, interval=prof.interval)
	      res = expr
	      Rprof(NULL)
	      t = summaryRprof(filename, chunksize=chunksize, memory="both")$sampling.time
	      mem = max(summaryRprof(filename, chunksize=chunksize, memory="both")$by.total$mem.total)
	      return(list(results=res, time=t, memory=mem))
}
# Example call:
#   sobj = load_seurat_object('small_test.RDS')
#   out = func_profiler(runSeurat(sobj, "batch"))
#   out$results is results
#   out$time is timing
#   out$memory is memory use

preP <- function(so, vars.to.regress=NULL, verbose=TRUE, n.pcs=100) {
  if (verbose) {
    message("Running Seurat v3 workflow")
  }
  so <- Seurat::FindVariableFeatures(object = so, verbose = verbose)
  so <- Seurat::ScaleData(object = so, verbose = verbose)
  so <- Seurat::RunPCA(object = so, npcs = n.pcs, verbose = verbose)
  return(so)
}

runConos = function(sobj, batch) {
	require(conos)
	require(Seurat)

      batch_list <- SplitObject(sobj, split.by=batch)
 	pp <- lapply(batch_list, preP)

	con <- Conos$new(pp)
	con$buildGraph(space="genes")
	con$findCommunities()
	con$embedGraph(method="UMAP")

	return(con)
}

saveConos = function(con, outdir) {
	dir.create(outdir)

	saveConosForScanPy(con, output.path=outdir,
                   pseudo.pca=TRUE, pca=TRUE,
                   verbose=TRUE)
}

runHarm = function(sobj, batch) {
	require(harmony)
	require(Seurat)

      sobj <- ScaleData(sobj)
	sobj <- RunPCA(sobj, features=rownames(sobj@assays$RNA))
	sobj <- RunHarmony(sobj, batch)
	sobj[['X_emb']] <- sobj[['harmony']]

      return(sobj)
}

runLiger = function(sobj, batch, hvg, k = 20, res = 0.4, small.clust.thresh = 20) {
  tryCatch(
    require(liger),
    warning = function (w) require(rliger)
  )
  require(Seurat)

  # Only counts is converted to liger object. To pass our own normalized data,
  # store it in the "counts" slot
  if (is.null(sobj@assays$RNA)) {
    # Seurat v4
    data <- GetAssayData(sobj, slot = "data")
    SetAssayData(sobj, slot = "counts", new.data = as.matrix(data))
  } else {
    # Seurat v3
    sobj@assays$RNA@counts = sobj@assays$RNA@data
  }

  # Create Liger object
  lobj = seuratToLiger(
    sobj,
    combined.seurat = T,
    meta.var = batch,
    renormalize = F,
    remove.missing = F
  )

  # We only pass nomarlized data, so store it as such
  lobj@norm.data <- lobj@raw.data

  # Assign hvgs
  lobj@var.genes <- hvg

  lobj <- scaleNotCenter(lobj, remove.missing = F) # Can't do our own scaling atm

  # Use tutorial coarse k suggests of 20.
  lobj <- optimizeALS(lobj, k = k, thresh = 5e-5, nrep = 3)

  lobj <- quantileAlignSNF(lobj, resolution = res, small.clust.thresh = small.clust.thresh)

  # Store embedding in initial Seurat object
  # Code taken from ligerToSeurat() function from LIGER
  inmf.obj <- new(
    Class = "DimReduc", feature.loadings = t(lobj@W),
    cell.embeddings = lobj@H.norm, key = "X_emb"
  )
  sobj@reductions['X_emb'] <- inmf.obj

  return(sobj)
}

runFastMNN = function(sobj, batch) {
  suppressPackageStartupMessages({
    require(batchelor)
  })

  if (is.null(sobj@assays$RNA)) {
    # Seurat v4
    expr <- GetAssayData(sobj, slot = "data")
  } else {
    # Seurat v3
    expr <- sobj@assays$RNA@data
  }

  sce <- fastMNN(expr, batch = sobj@meta.data[[batch]])
  corrected_data <- assay(sce, "reconstructed")

  if (is.null(sobj@assays$RNA)) {
    # Seurat v4
    sobj <- SetAssayData(sobj, slot = "data", new.data = as.matrix(corrected_data))
    sobj@reductions['X_emb'] <- CreateDimReducObject(reducedDim(sce, "corrected"), key = 'fastmnn_')
  } else {
    # Seurat v3
    sobj@assays$RNA <- CreateAssayObject(corrected_data)
    sobj[['X_emb']] <- CreateDimReducObject(reducedDim(sce, "corrected"), key = 'fastmnn_')
  }

  return(sobj)
}
