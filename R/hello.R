# package to install RAVE

.onAttach <- function(libname, pkgname){
  # load RAVE
  pkgs = utils::installed.packages()[,1]
  if(!'rave' %in% pkgs){
    # need_devtools = TRUE
    # if('devtools' %in% pkgs){
    #   ver = utils::packageVersion('devtools')
    #   if(utils::compareVersion(
    #     as.character(ver), '1.13.4'
    #   ) >= 0){
    #     need_devtools = FALSE
    #   }
    # }
    #
    # if(need_devtools){
    #   opt = options('repos')
    #   if(length(opt$repos)){
    #     repos = opt$repos[1]
    #   }else{
    #     repos = "https://cloud.r-project.org"
    #   }
    #   install.packages('devtools', repos = repos)
    # }

    # install rhdf5
    source("https://bioconductor.org/biocLite.R")
    bioc_p = c("rhdf5", "HDF5Array")
    bioc_p = bioc_p[!bioc_p %in% pkgs]
    if(length(bioc_p)){
      biocLite(bioc_p, suppressUpdates = T, suppressAutoUpdate = T)
    }

    # install rave
    tryCatch({
      readLines('https://raw.githubusercontent.com/beauchamplab/rave/master/Recommend.md')[1]
    }, error = function(e){
      return('master')
    })->
      ref
    devtools::install_github('beauchamplab/rave', ref = ref)
    do.call('require', args = list(
      package = 'rave',
      character.only = TRUE
    ))
  }
}

