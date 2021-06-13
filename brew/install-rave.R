repos <- "https://cloud.r-project.org"
# Check if remotes is installed
if(!require(remotes)){
  utils::install.packages(
    pkgs = "remotes",
    repos = repos,
    clean = TRUE,
  )
}

inst_github <- function(..., upgrade = 'always'){
  remotes::install_github(
    repo = c(...),
    upgrade = upgrade,
    repos = repos,
    dependencies = TRUE,
    Ncpus = parallel::detectCores()
  )
}

# This will bugged out
inst_github("beauchamplab/rave")
inst_github("beauchamplab/ravebuiltins@migrate2")

# Finalize installation
rave::check_dependencies(update_rave = FALSE, restart = FALSE, nightly = TRUE, demo_data = TRUE)

# N27 Brain
invisible(threeBrain::merge_brain())



