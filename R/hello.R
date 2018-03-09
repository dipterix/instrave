# package to install RAVE
local({
  
  pkgs = utils::installed.packages()[,1]
  if(! 'devtools' %in% pkgs){
    install.packages('devtools')
  }
  
  
  
  bioc_p = c("rhdf5", "HDF5Array")
  
  bioc_p = bioc_p[! bioc_p %in% utils::installed.packages()[,1]]
  if(length(bioc_p)){
    source("https://bioconductor.org/biocLite.R")
    biocLite(bioc_p, suppressUpdates = T, suppressAutoUpdate = T)
  }
  
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
      tryCatch({
        p = x[2]; v = x[3]
        if(p == 'stringr'){
          return('')
        }
        ni = TRUE
        if(p %in% pkgs){
          if(v == '' || utils::compareVersion(v, as.character(packageVersion(p))) <= 0){
            ni = FALSE
          }
        }
        if(ni){
          return(p)
        }else{
          return('')
        }
      }, error = function(e){
        return('')
      }) ->
        p
      p
    }) ->
      ips
    ips = ips[ips != '']
    if(length(ips)){
      assign('..instrave_packages', ips, envir = globalenv())
      ..instrave_packages = ips
      install.packages(..instrave_packages)
    }
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
  
  # if(!'rave' %in% pkgs){
  # }
})

