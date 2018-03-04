# package to install RAVE

.onLoad <- function(libname, pkgname){
  # load RAVE


  pkgs = utils::installed.packages()[,1]
  if(!'rave' %in% pkgs){

    # install rhdf5
    source("https://bioconductor.org/biocLite.R")
    bioc_p = c("rhdf5", "HDF5Array")
    bioc_p = bioc_p[!bioc_p %in% pkgs]
    if(length(bioc_p)){
      message('Installing Bioconductor Dependencies...')
      biocLite(bioc_p, suppressUpdates = T, suppressAutoUpdate = T)
    }

    # install rave
    tryCatch({
      readLines('https://raw.githubusercontent.com/beauchamplab/rave/master/Recommend.md')[1]
    }, error = function(e){
      return('master')
    })->
      ref


    message('This is RAVE (', ref, ')')
    message('Installing RAVE - this might take a while..... (10 Min?)')
    devtools::install_github('beauchamplab/rave', ref = ref, quiet = F)
    do.call('require', args = list(
      package = 'rave',
      character.only = TRUE
    ))
  }
}

