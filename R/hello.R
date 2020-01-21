# Code to check install RAVE
rm(list = ls(), envir = globalenv())

RVERSION = '3.6.0'
CMD = "source('https://raw.githubusercontent.com/dipterix/instrave/master/R/hello.R', echo = FALSE)"
RAVEREPO = 'beauchamplab/rave@dev-0.1.9'

load_pkg <- function(pkg, type = 'binary'){
  if( system.file('', package = pkg) == '' ){
    cat('Installing package ', pkg, '\n')
    cmd = sprintf("install.packages('%s', type = '%s', verbose = FALSE)", pkg, type)
    eval(parse(text = cmd))
  }
}

get_os <- function(){
  os <- R.version$os
  load_pkg('stringr')
  if(stringr::str_detect(os, '^darwin')){
    return('darwin')
  }
  if(stringr::str_detect(os, '^linux')){
    return('linux')
  }
  if(stringr::str_detect(os, '^solaris')){
    return('solaris')
  }
  if(stringr::str_detect(os, '^win')){
    return('windows')
  }
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
  rstudioapi::restartSession(cmd)
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
    readline('Please press Enter once "homebrew" is installed:')
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

message('STEP 1: check system requirement')

test_r_ver = check_r_version()

if(!test_r_ver){
  message('R version is too low. Recommended verson: ', RVERSION)
  
  switch (
    os_name,
    'darwin' = {
      # download R
      readline('Press any key to proceed to download page...')
      utils::browseURL('https://cran.r-project.org/bin/macosx/')
    },
    'windows' = {
      readline('Please download *R* and *Rtools*. Press any key to proceed to download page...')
      browseURL('https://cran.r-project.org/bin/windows/Rtools/')
      browseURL('https://cran.r-project.org/bin/windows/')
    },
    {
      readline('Press any key to proceed to download page...')
      browseURL('https://cran.r-project.org/')
    }
  )
  
  if(has_rstudio()){
    readline('Please press any key when R is installed and updated:')
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
    readline('Please press Enter once Commandline Tool is installed:')
  }
  
  # install fftw
  try({
    load_pkg('fftw')
    load_pkg('fftwtools')
  })
  if(system.file('', package = 'fftw') == ''){
    suppressWarnings(install_fftw_macos())
  }
  
}

message('STEP 2: check install devtools')

cat('install.packages("devtools")\n')
load_pkg('devtools')
update.packages('devtools', ask = 'graphics', type = 'binary')

message('STEP 3: install RAVE and its dependencies')
load_pkg('remotes')
load_pkg('dipsaus')

cat(sprintf('devtools::install_github("%s")\n', RAVEREPO))
remotes::install_github(RAVEREPO, force = FALSE, upgrade = FALSE)


message('STEP 4: check updates')
cat("rave::check_dependencies()\n")
rave::check_dependencies()

message('STEP 5: download N27 brain')
cat("threeBrain::brain_setup()\n")
n27 = threeBrain::merge_brain()

message('STEP 6: RAVE setting')
cat('Check RAVE repositories\n')
capture.output({
  rave::arrange_modules(refresh = TRUE, reset = FALSE)
  rave::arrange_data_dir(FALSE, FALSE)
})
data_dir = rave::rave_options('data_dir')
raw_data_dir = rave::rave_options('raw_data_dir')

if(!dir.exists(data_dir) || !dir.exists(raw_data_dir)){
  message('Cannot find valid RAVE data repository paths. Please locate them!')
  
  if(has_rstudio()){
    if(!dir.exists(raw_data_dir)){
      readline(paste0('Please select ', sQuote('RAW'), 
                      ' data directory. Press Enter key to continue:'))
      raw_data_dir = rstudioapi::selectDirectory(caption = 'Select RAW data directory', 
                                                 path = '~/rave_data/raw_dir')
      if(length(raw_data_dir) && dir.exists(raw_data_dir)){
        rave::rave_options('raw_data_dir' = raw_data_dir)
      }
    }
    if(!dir.exists(data_dir)){
      readline(paste0('Please select ', sQuote('RAVE Repo'),
                      ' directory. Press Enter key to continue:'))
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

# check if subject exists
has_YAB = FALSE
projects = rave::get_projects()
if('demo' %in% projects){
  subjects = rave::get_subjects('demo')
  if('YAB' %in% subjects){
    has_YAB = TRUE
  }
}
if(!has_YAB){
  message('STEP 7: download demo subject YAB')
  ans = dipsaus::ask_yesno('Do you want to download sample data? ~ 1.5GB')
  
  if(isTRUE(ans)){
    rave::download_sample_data('YAB')
    
    # install group data
    dirs = rave::get_dir('_project_data', 'demo')
    if(!dir.exists(dirs$subject_dir)){
      rave::download_sample_data('_group_data')
    }
    
    rm(list = ls(), envir = globalenv())
    # Start rave!
    app = rave::start_rave()
  }
}else{
  rm(list = ls(), envir = globalenv())
  app = rave::start_rave()
}

ans = dipsaus::ask_yesno('Want to launch RAVE main application?')
if(isTRUE(ans)){
  print(app)
}






