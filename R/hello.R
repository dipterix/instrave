# Code to check install RAVE
rm(list = ls(), envir = globalenv())


RVERSION = '3.6.0'
CMD = "source('https://raw.githubusercontent.com/dipterix/instrave/master/R/hello.R', echo = FALSE)"
RAVEREPO = 'beauchamplab/rave'
PKG_TYPE = 'binary'
load_pkg <- function(pkg, type = 'binary', min_ver = NA, tried = 1){
  
  cmd = sprintf("install.packages('%s', type = '%s', verbose = FALSE)", pkg, type)
  if( system.file('', package = pkg) == '' ){
    cat('Installing package ', pkg, '\n')
    eval(parse(text = cmd))
  }else if(!is.na(min_ver)){
    if(compareVersion(as.character(packageVersion(pkg)), min_ver) < 0){
      # update
      eval(parse(text = cmd))
    }
  }
  if(tried > 0){
    load_pkg(pkg, 'source', min_ver = min_ver, tried = 0)
  }
}

get_os <- function(){
  os <- R.version$os
  load_pkg('stringr')
  load_pkg('stringi')
  
  if(stringr::str_detect(os, '^darwin')){
    return('darwin')
  }
  if(stringr::str_detect(os, '^linux')){
    PKG_TYPE <<- 'source'
    return('linux')
  }
  if(stringr::str_detect(os, '^solaris')){
    PKG_TYPE <<- 'source'
    return('solaris')
  }
  if(stringr::str_detect(os, '^win') || os == 'mingw32'){
    return('windows')
  }
  PKG_TYPE <<- 'source'
  return('unknown')
}

check_r_version <- function(req = RVERSION){
  sess = sessionInfo()
  ver = sprintf('%s.%s', sess$R.version$major, sess$R.version$minor)
  if(utils::compareVersion(ver, req) < 0){
    return(FALSE)
  }
  return(TRUE)
}

has_rstudio <- function(){
  load_pkg('rstudioapi')
  isTRUE(try({rstudioapi::isAvailable()}, silent = TRUE))
}

restart <- function(cmd = CMD){
  .rs.restartR(cmd)
}

id = NULL
if(has_rstudio()){
  try({
    id = rstudioapi::terminalList()[[1]]
  }, silent = TRUE)
}
# system <- function(cmd, ..., show = FALSE){
#   if(has_rstudio()){
#     # run command
#     if(is.null(id) || !rstudioapi::terminalRunning(id)){
#       id <<- rstudioapi::terminalCreate(show = FALSE)
#     }
#     if(!stringr::str_ends(cmd, '\n')){
#       cmd = paste0(cmd, '\n')
#     }
#     rstudioapi::terminalClear(id)
#     rstudioapi::terminalActivate(id, show = show)
#     rstudioapi::terminalSend(id, cmd)
#     while (isTRUE(rstudioapi::terminalBusy(id))) {
#       Sys.sleep(1);
#     }
#     rstudioapi::sendToConsole('', execute = FALSE, echo = FALSE, focus = TRUE)
#     exitcode = rstudioapi::terminalExitCode(id)
#     res = rstudioapi::terminalBuffer(id)
#     attr(res, 'status') = exitcode
#
#     res
#   }else{
#     base::system(cmd, ...)
#   }
# }


os_name = get_os()



install_brew_macos <- function(){
  # install brew
  brew_path = system('which brew', intern = TRUE, ignore.stderr = FALSE)
  if(!length(brew_path) || isTRUE(attr(brew_path,"status") == 1) || isTRUE(brew_path == '')){
    
    cat('Homebrew not installed. In the newly opened terminal, paste the following command line\n')
    message('/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"')
    cat('and hit Enter. Follow the instructions to install brew')
    system('open -a "Terminal" --new', wait = FALSE, intern = FALSE)
    readline('Please press Enter/Return once "homebrew" is installed:')
  }
}

install_fftw_macos <- function(){
  path = system('which fftw', intern = TRUE)
  if(!length(path) || isTRUE(attr(path,"status") == 1) || isTRUE(path == '')){
    # install brew
    install_brew_macos()
    cat("system('brew install pkg-config')\n")
    system('brew install pkg-config')
    cat("system('brew install fftw')\n")
    system('brew install fftw')
  }
}

cat('=========== Welcome to RAVE installer ===========\n')
#### STEP 1: check system requirement ####
message('STEP 1: check system requirement')

test_r_ver = check_r_version()

if(!test_r_ver){
  message('R version is too low. Please download R with versions greater or equal to ', RVERSION)
  
  inst_path = '~/Downloads/RAVE_installer'
  
  switch (
    os_name,
    'darwin' = {
      # download R
      readline('Press Enter/Return to download and install latest R:')
      # create a download folder in ~/Download
      dir.create(inst_path, recursive = TRUE)
      download.file(
        'https://cran.r-project.org/bin/macosx/el-capitan/base/R-latest.pkg',
        file.path(inst_path, 'R-latest.pkg'))
      
      instr_cmd = sprintf('open "%s"', 
                          normalizePath(file.path(inst_path, 'R-latest.pkg')))
      
      system(instr_cmd)
      
    },
    'windows' = {
      readline('Please download *R* and *Rtools*. Press Enter/Return to proceed to download page...')
      browseURL('https://cran.r-project.org/bin/windows/Rtools/')
      browseURL('https://cran.r-project.org/bin/windows/')
    },
    {
      readline('Press Enter/Return to proceed to download page...')
      browseURL('https://cran.r-project.org/')
    }
  )
  
  if(has_rstudio()){
    readline('Please press Enter/Return when R is installed and updated:')
    restart()
  }else{
    stop('R version too low. Please download newest R and restart the session')
  }
  
}

if(os_name == 'windows'){
  # TODO check if Rtools is installed
}else if(os_name == 'darwin'){
  # Check if commandline tool is installed
  cat('system("xcode-select --install")   # install MacOS system commandline tools\n')
  suppressWarnings({
    res = system('xcode-select --install', wait = TRUE, intern = TRUE,
                 ignore.stderr = TRUE, ignore.stdout = FALSE)
  })
  
  if(!isTRUE(attr(res,"status") == 1)){
    readline('Please press Enter/Return once Commandline Tool is installed:')
  }
  
  # install fftw
  try({
    load_pkg('fftw')
    load_pkg('fftwtools')
  })
  if(system.file('', package = 'fftw') == ''){
    suppressWarnings(install_fftw_macos())
  }
  
}else{
  # linux: install 
  cat('Your system might need the following tools to compile if using Ubuntu 16:\n',
      'libssl-dev libcurl4-openssl-dev libssh2-1-dev libv8-3.14-dev libxml2-dev libfftw3-dev libtiff5-dev libhdf5-dev\n',
      '\n If you are using other systems. Please search for the corrresponding system packages')
  readline('Please press Enter/Return if you have them installed:')
}

#### STEP 2: check install devtools ####
message('STEP 2: check install devtools')

cat('install.packages("devtools")\n')
load_pkg('devtools', min_ver = '2.2.0')

#### STEP 3: install RAVE and its dependencies ####
message('STEP 3: install RAVE and its dependencies')
load_pkg('remotes')
load_pkg('dipsaus', min_ver = '0.0.4')
load_pkg('dipsaus', min_ver = '0.0.4', type = 'source')
load_pkg('threeBrain', min_ver = '0.1.5', type = 'source')

cat(sprintf('devtools::install_github("%s")\n', RAVEREPO))
remotes::install_github(RAVEREPO, force = FALSE, upgrade = TRUE, type = PKG_TYPE)
# tryCatch({
# }, error = function(e){
#   # install from compiled version
#   remotes::install_url('https://github.com/beauchamplab/rave/archive/v0.1.9-beta.tar.gz')
# })

#### STEP 4: check updates ####
message('STEP 4: check updates')
cat("rave::check_dependencies(restart = FALSE)\n")
remotes::install_github("dipterix/rutabaga@develop", upgrade = FALSE, force = FALSE)
remotes::install_github("dipterix/threeBrain", upgrade = FALSE, force = FALSE)
remotes::install_github("beauchamplab/ravebuiltins@migrate2", upgrade = FALSE, force = FALSE)
remotes::install_github("dipterix/dipsaus", upgrade = FALSE, force = FALSE)





#### STEP 5: download N27 brain ####
message('STEP 5: download N27 brain')
cat("threeBrain::brain_setup()\n")
n27 = threeBrain::merge_brain()

#### STEP 6: RAVE setting ####
message('STEP 6: RAVE setting')
cat('Check RAVE repositories\n')
capture.output({
  rave::arrange_modules(refresh = TRUE, reset = FALSE)
  rave::arrange_data_dir(TRUE, FALSE)
})
data_dir = rave::rave_options('data_dir')
raw_data_dir = rave::rave_options('raw_data_dir')

if(!dir.exists(data_dir) || !dir.exists(raw_data_dir)){
  message('Cannot find valid RAVE data repository paths. Please locate them!')
  
  if(has_rstudio()){
    if(!dir.exists(raw_data_dir)){
      readline(paste0('Please select ', sQuote('RAW'), 
                      ' data directory. Press Enter/Return key to continue:'))
      raw_data_dir = rstudioapi::selectDirectory(caption = 'Select RAW data directory', 
                                                 path = '~/rave_data/raw_dir')
      if(length(raw_data_dir) && dir.exists(raw_data_dir)){
        rave::rave_options('raw_data_dir' = raw_data_dir)
      }
    }
    if(!dir.exists(data_dir)){
      readline(paste0('Please select ', sQuote('RAVE Repo'),
                      ' directory. Press Enter/Return key to continue:'))
      data_dir = rstudioapi::selectDirectory(caption = 'Select RAVE data directory',
                                             path = '~/rave_data/data_dir/')
      if(length(data_dir) && dir.exists(data_dir)){
        rave::rave_options('data_dir' = data_dir)
      }
    }
  }
  
  if(!length(raw_data_dir) || !dir.exists(raw_data_dir) || 
     !length(data_dir) || !dir.exists(data_dir)){
    message('Please enter correct \n\t', 
            sQuote('Raw subject data path'), ' - where raw iEEG data are stored\n\t',
            sQuote('RAVE subject data path'),' - where RAVE root directory locates\n',
            'in the browser.')
    print(rave::rave_options())
  }
  
}

#### STEP 7: download demo subject  ####
message('STEP 7: download demo subject')
# check demo subject
demo_subjects = rave::get_subjects('demo')
sample_subs = c('KC', 'YAB', 'YAD', 'YAF', 'YAH', 'YAI', 'YAJ', 'YAK')
installed_subjects = sample_subs %in% demo_subjects
if(!all(installed_subjects)){
  d = which(!installed_subjects)[[1]]
}else{
  d = 11
}
s = c(
  'Install demo subject(s)? Enter the numbers to proceed (use comma to seperate, like 1,2,4)\n',
  paste(' ', seq_along(sample_subs), ':', sample_subs, c('', '(installed)')[installed_subjects + 1], '\n'),
  sprintf('  %d : All above\n', length(sample_subs) + 1),
  sprintf('  %d : All of the above that are not already installed\n', length(sample_subs) + 2),
  sprintf('  11 or any other input: None\n')
)
ans = do.call(dipsaus::ask_or_default, c(as.list(s), list(default = d)))

ans = dipsaus::parse_svec(ans)
ans = ans[!is.na(ans)]
ans = ans[ans %in% 1:11]
if(!length(ans)){ ans = 11 }

if(!11 %in% ans){
  if( 9 %in% ans ){
    ans = 1:8
  }else if(10 %in% ans){
    ans = !installed_subjects
  }
}else{
  ans = 11
}
subs = sample_subs[ans]
subs = subs[!is.na(subs)]
if(length(subs)){
  ans = dipsaus::ask_yesno('The following subject(s) are to be downloaded. \n\t',
                     paste(subs, collapse = ', '), '\n',
                     'WARNING: Any subject in ', sQuote('demo'),
                     ' project will be overridden if they exist.\n',
                     'Enter yes/y to proceed, or no/n to cancel.')
  if(isTRUE(ans)){
    for(sub in subs){
      rave::download_sample_data(sub, replace_if_exists = TRUE)
      try({
        brain = rave::rave_brain2(sprintf('demo/%s', sub))
      })
    }
    
    # install group data
    dirs = rave::get_dir('_project_data', 'demo')
    if(!dir.exists(dirs$subject_dir)){
      rave::download_sample_data('_group_data')
    }
  }
}

rm(list = ls(envir = globalenv()), envir = globalenv())

ans = dipsaus::ask_yesno('Want to launch RAVE main application?')
if(isTRUE(ans)){
  f = get0('.rs.restartR', envir = globalenv(), ifnotfound = NULL)
  if(is.function(f)){
    f('rave::start_rave()')
  }else{
    rave::start_rave()
  }
}






