repos <- "https://cloud.r-project.org"


# Check if packages can be loaded
libpath <- system.file('', package = 'usethis')
if(libpath != ''){
  # check if libpath is from ~/
  cmp <- normalizePath('~')
  if(base::strtrim(libpath, nchar(cmp)) == cmp){
    tryCatch({
      require(usethis, quietly = TRUE, warn.conflicts = FALSE)
    }, error = function(e){
      message("Package usethis was installed in user's libPath but cannot be loaded. ",
              "Guessing the old libraries are not compatible with current R... ",
              "\n  REMOVING user's library and install a new one")
      paths <- list.dirs(dirname(libpath), full.names = TRUE, recursive = FALSE)
      for(f in paths){
        unlink(f, recursive = TRUE, force = TRUE)
      }
    })
  }
}


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

# N27 Brain
invisible(threeBrain::merge_brain())

rave::check_dependencies(update_rave = FALSE, restart = FALSE, nightly = TRUE, demo_data = TRUE)


