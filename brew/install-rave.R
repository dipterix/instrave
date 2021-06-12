repos <- "https://cloud.r-project.org"
# Check if remotes is installed
if(!require(remotes)){
  utils::install.packages(
    pkgs = "remotes",
    repos = repos,
    clean = TRUE,
    type = 'source'
  )
}

inst_github <- function(..., upgrade = 'always'){
  remotes::install_github(
    repo = c(...),
    upgrade = upgrade,
    repos = repos,
    type = 'source',
    dependencies = TRUE,
    Ncpus = parallel::detectCores()
  )
}

# if(!require(docopt)){
#   utils::install.packages(
#     pkgs = "docopt",
#     repos = repos,
#     clean = TRUE,
#     type = 'source'
#   )
# }
# 
# doc <- "Usage: install-rave [(BREW_PATH)]
# 
# -h --help                   show this help text
# 
# Required:
#   BREW_PATH                 Brew path
# 
# Example: install-rave /opt/Homebrew
# 
# "
# opt <- docopt::docopt(doc)
# 
# 
# 
# # Add brew to path /opt/homebrew/bin:/opt/homebrew/sbin
# if(!length(opt$BREW_PATH) || !file.exists(file.path(opt$BREW_PATH, 'bin', 'brew'))){
#   stop("Cannot find brew")
# }
# # locate h5cc
# # /usr/local/Cellar/hdf5/
# hdf5_dir <- file.path(opt$BREW_PATH, 'Cellar', 'hdf5')

# # install hdf5 now -- #{HOMEBREW_PREFIX}/bin/h5cc
# utils::install.packages(
#   "hdf5r",
#   repos = repos,
#   clean = TRUE,
#   type = 'source', 
#   configure.args = sprintf("--with-hdf5=/opt/homebrew/bin/h5cc")
# )

# This will bugged out
inst_github("beauchamplab/rave")
inst_github("beauchamplab/ravebuiltins@migrate2")







