# Title     : Install all R integration methods
# Created by: mumichae
# Created on: 6/4/21

suppressPackageStartupMessages({
  library(optparse)
  library(data.table)
})

optparse_list <- list(
  make_option(
    c("-d", "--dependencies"),
    type = "character",
    help = "Dependency TSV file with R packages & versions",
    metavar = "character"
  ),
  make_option(
    c("-q", "--quiet"),
    type = 'logical',
    default = FALSE,
    action = "store_true",
    help = "Quiet install"
  )
)


opt_parser <- OptionParser(option_list = optparse_list)
opt <- parse_args(opt_parser)

options(repos = structure(c(CRAN = 'https://cloud.r-project.org')), warn = -1)

installed <- as.data.table(installed.packages())

packages <- fread(cmd = paste("grep -v '#'", opt$dependencies))
message('Dependencies:')
print(packages)

for (pckg_name in packages$package) {
  package_dt <- packages[package == pckg_name]
  pckg_name <- gsub(".*/", "", pckg_name)
  version <- package_dt$version
  how <- package_dt$how

  if (
    !(pckg_name %in% installed$Package) ||
      (
        !is.na(version)
          && compareVersion(installed[Package == pckg_name, Version], version) < 0
      )
  ) {

    package <- package_dt$package
    message(paste("install", package))
    if (how == 'cran') {
      install.packages(package, quiet = opt$quiet)
    } else if (how == 'version') {
      devtools::install_version(package, version = version, quiet = opt$quiet)
    } else if (how == 'BioC') {
      BiocManager::install(package, quiet = opt$quiet)
    } else if (how == 'github') {
      package_string <- ifelse(is.na(version), package, paste0(package, '@v', version))
      message('install ', package_string, ' from Github')
      devtools::install_github(package_string, quiet = opt$quiet)
    } else {
      stop(pckg_name, ' cannot be installed via: ', how)
    }
    message(paste("installed", package))
  }
  message('import ', pckg_name)
  suppressPackageStartupMessages(library(pckg_name, character.only = TRUE))
}

sessionInfo()
