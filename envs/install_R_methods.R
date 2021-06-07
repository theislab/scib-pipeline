# Title     : Install all R integration methods
# Created by: mumichae
# Created on: 6/4/21
suppressPackageStartupMessages(library(data.table))

options(repos = structure(c(CRAN = 'https://cloud.r-project.org')), warn = -1)
quiet <- FALSE

installed <- as.data.table(installed.packages())

packages <- data.table(
  package = c('RcppAnnoy', 'Seurat', 'welch-lab/liger', 'kharchenkolab/conos',
              'kharchenkolab/conosPanel', 'immunogenomics/harmony'),
  version = c('0.0.14', '3.1.1', '0.5.0', '1.3.0', NA, NA),
  how = c('version', 'version', 'github', 'github', 'github')
)
# 'batchelor', NA, 'BioC'

for (pckg_name in packages$package) {
  package_dt <- packages[package == pckg_name]
  pckg_name <- gsub(".*/", "", pckg_name)
  version <- package_dt$version
  how <- package_dt$how

  if (
    !pckg_name %in% installed$Package || (!is.na(version)
      && compareVersion(installed[Package == pckg_name, Version], version) < 0)
  ) {

    package <- package_dt$package
    message(paste("install", package))
    if (how == 'version') {
      devtools::install_version(package, version = version, quiet = quiet)
    } else if (how == 'BioC') {
      BiocManager::install(package, quiet = quiet)
    } else if (how == 'github') {
      package_string <- ifelse(is.na(version), package, paste(package, version, sep = '@'))
      devtools::install_github(package_string, quiet = quiet)
    } else {
      stop(pckg_name, ' cannot be installed via: ', how)
    }
    message(paste("installed", package))
  }
  suppressPackageStartupMessages(library(pckg_name, character.only = TRUE))
}

devtools::install_version('RcppAnnoy', version = '0.0.14', quiet = quiet)
BiocManager::install('batchelor', quiet = quiet)
devtools::install_version('Seurat', version = '3.2.0', quiet = quiet)
devtools::install_github('welch-lab/liger@v0.5.0', quiet = quiet)
devtools::install_github('kharchenkolab/conos@v1.3.0', quiet = quiet)
devtools::install_github('immunogenomics/harmony', quiet = quiet)

sessionInfo()
