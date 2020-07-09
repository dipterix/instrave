
# installation script using rstudio api

# Set repos
repos = c(
  'CRAN' = "https://cran.rstudio.com/",
  'dipterix' = "https://dipterix.github.io/drat/"
)


installr <- function(...){
  install.packages(c(...), repos = repos)
}
detect_package <- function(p){
  system.file('', package = p) != ''
}

# check whether in RStudio environment and versions
if(!requireNamespace('rstudioapi')){
  installr('rstudioapi')
}

is_rstudio_env <- rstudioapi::isAvailable(version_needed = '1.3', child_ok = TRUE)

if(!is_rstudio_env){
  stop("RStudio is not running. Please run script within RStudio (version >= 1.3)")
}

# Check if commandline tools is installed

cat('Installing commandline tools\n')

# On OSX, it installs commandline tool
if( !rstudioapi::buildToolsCheck() ){
  rstudioapi::buildToolsInstall("Model compilation")
}

while( !rstudioapi::buildToolsCheck() ){
  Sys.sleep(1)
}


# ---- Check whether user library is created
vars <- c("R_LIBS", "R_LIBS_SITE", "R_LIBS_USER")
for (var in vars) {
  path <- Sys.getenv(var)
  if (!nzchar(path)) next
  is_dummy <- grepl("^[.]", path) && !grepl("[/\\]", path)
  if (is_dummy) next
  paths <- unlist(strsplit(path, split = .Platform$path.sep, fixed = TRUE))
  paths <- unique(paths)
  paths <- paths[!vapply(paths, FUN = dir.exists, FUN.VALUE = FALSE)]
  if ( length(paths) ) {
    tryCatch({
      for(p in paths){
        dir.create(p, recursive = TRUE, showWarnings = FALSE)
        if(dir.exists(p)){
          .libPaths(p)
        }
      }
    })
  }
}



# upgrade packages
# try({
#   update.packages(repos = repos)
# }, silent = TRUE)

# install startup to avoid previous installation warnings

if(detect_package('startup')){
  tryCatch({
    # remove startup scripts
    startup::uninstall()
  }, error = function(e){})
  unloadNamespace('startup')
  remove.packages('startup', lib = .libPaths())
}

cat('Installing dependencies - startup, Rcpp\n')
installr("startup")


# If reticulate is installed, Rcpp won't upgrade
if(detect_package('reticulate')){
  remove.packages('reticulate', lib = .libPaths())
}

installr("Rcpp")

installr("reticulate")


# this will install rutabaga, dipsaus, threeBrain and rave. However, the versions might be wrong
cat('Upgrading modules - ravebuiltins\n')
installr('ravebuiltins')

# Installs rave to ensure it's correct
cat('Upgrading main app - rave\n')
installr('rutabaga', 'rave')

# install threeBrain - 3D viewer
cat('Upgrading 3D viewer - threeBrain\n')
installr('threeBrain')

# install dipsaus
cat('Upgrading utils\n')
installr('dipsaus')

# Now check 3D brain
cat("Checking N27 brain\n")
threeBrain::merge_brain()

# Register startup events
startup::install(overwrite = FALSE)

cat("Done\n")


