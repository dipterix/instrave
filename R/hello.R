# package to install RAVE
local({
  install.packages('devtools')
  pkgs = utils::installed.packages()[,1]
  source("https://bioconductor.org/biocLite.R")
  bioc_p = c("rhdf5", "HDF5Array")
  
  if(!'stringr' %in% pkgs){
    install.packages('stringr')
  }
  
  # check rave dependencies
  
  descr = readLines('https://raw.githubusercontent.com/beauchamplab/rave/rave-dipterix/DESCRIPTION')
  start = which(stringr::str_detect(descr, '^Imports:')) + 1
  end = which(stringr::str_detect(descr, '^Collate:')) - 1
  tryCatch({
    stringr::str_match(stringr::str_trim(descr[start:end]), "^([^\\(,\\ ]*)[^0-9]*([0-9\\.\\-]*)")
  }, error = function(e){
    NULL
  }) ->
    imports
  
  if(!is.null(imports)){
    apply(imports, 1, function(x){
      try({
        pkgs = utils::installed.packages()[,1]
        p = x[2]; v = x[3]
        ni = TRUE
        if(p %in% pkgs){
          if(v == '' || utils::compareVersion(v, as.character(packageVersion(p))) <= 0){
            ni = FALSE
          }
        }
        
        if(ni){
          if(p %in% bioc_p){
            biocLite(p, suppressUpdates = T, suppressAutoUpdate = T)
          }else{
            install.packages(p, type = 'binary')
          }
        }
      })
    })
  }
  
  
  if(!'rave' %in% pkgs){
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
})

