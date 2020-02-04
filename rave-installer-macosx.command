#!/bin/sh

# register global variables

R_VER_MAJOR=3
R_VER_MINOR=6
R_VER_DEV=0
INST_PATH="$HOME/Downloads/RAVE_install"
N27_PATH="$HOME/rave_data/others/three_brain/N27/"
HOME_BSLASH=$(echo "$HOME" | sed "s/\//\\\\\\\\/g")
DEMO_SUB_STR="All All_that_are_not_installed KC YAB YAD YAF YAH YAI YAJ YAK"
DEMO_SUBS=( $DEMO_SUB_STR );
RUN_R="Rscript --no-save --no-restore --no-site-file --no-init-file"
ALLYES=1

if [ "$#" -ne 1 ]; then
  start_step=0
else
  start_step="$1"
fi


echo $start_step
#exit 0

clear -x
echo "============ Welcome to RAVE installer (MacOS) ============";
echo "[RAVE]: Step 1: check system requirement..."

# Check if R installed or R version is too low
r_need_install=0

if ! [ -x "$(command -v R)" ]; then
  echo "[RAVE]: R is not detected by command - which R"
  r_need_install=1
else	

  r_path=$(which R)
  echo "[RAVE]: R found at $r_path."

  # check R version
  r_version=$(R --version 2>&1 | grep 'R version ' | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')
  r_ver_major=$(echo $r_version | egrep -o '^[0-9]+')
  r_ver_minor=$(echo $r_version | egrep -o '([0-9]+)\.[0-9]+$' | egrep -o '^[0-9]+')
  r_ver_dev=$(echo $r_version | egrep -o '[0-9]+$')

	
  if [ $r_ver_major -lt $R_VER_MAJOR ]; then
    echo "[RAVE]: R major version is too low"
    r_need_install=1
  elif [ $r_ver_minor -lt $R_VER_MINOR ]; then
    echo "[RAVE]: R minor version is too low"
    r_need_install=1
  elif [ $r_ver_dev -lt $R_VER_DEV ]; then
    echo "[RAVE]: R minor version is too low"
    r_need_install=1
  fi
fi

# r_need_install=1

# If r_need_install > 0, need to install latest version of R
if [ $r_need_install -gt 0 ]; then
  # download to ~/Download/RAVE_install
  echo "[RAVE]: Downloading latest version of R from CRAN"
  mkdir -p "$INST_PATH"
  curl "https://cran.r-project.org/bin/macosx/el-capitan/base/R-latest.pkg" > "$INST_PATH/R-latest.pkg"
  
  clear -x
  echo "[RAVE]: Waiting for the installer. Please follow the instructions from the R installer"
  open -W "$INST_PATH/R-latest.pkg"
fi

# check install xcode command line
( (
  xcode-select --install 2>/dev/null
) && {
  clear -x
  read -p "Press Enter/Return once command line tools are installed: "
} ) || {
  echo "[RAVE]: Command line tools are already installed (skip)"
}


# install RStudio

if [ ! -d "/Applications/RStudio.app" ]; then
  # install RStudio. check version? 
  # plutil -p /Applications/RStudio.app/Contents/Info.plist | grep CFBundleShortVersionString | grep -o "[[:digit:].]\+"
  
  # INST_PATH="$HOME/Downloads/RAVE_install"
  # curl 
  mkdir -p $INST_PATH
  curl "https://rstudio.com/products/rstudio/download/#download" >> $INST_PATH/rstudio.html
  RSTUDIO_URL=$(cat $INST_PATH/rstudio.html | grep -o --max-count=1 "https://download1.rstudio.org/desktop/macos/RStudio-[[:digit:].]\+.dmg")
  curl $RSTUDIO_URL >> $INST_PATH/rstudio.dmg
  
  RSTUDIO_FNAME=$(echo $RSTUDIO_URL | grep -o "RStudio-[[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+")
  
  open $INST_PATH/rstudio.dmg
  clear -x
  
  echo "[RAVE]: Please drag RStudio.app to your Application folder to install RStudio"
  read -p "Once installed, press Enter/Return to continue..."
  
fi


clear -x
# install packages for R
echo "[RAVE]: Step 2: Install/Update RAVE and its dependencies"

if [ $start_step -gt 0 ]; then
  echo "[RAVE]: skipped"
else
  # Rcpp
  ($RUN_R -e "utils::install.packages('Rcpp',type='binary',repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'Rcpp'"
    exit 1
  }
  # stringr
  ($RUN_R -e "utils::install.packages('stringr',type='binary',repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'stringr'"
    exit 1
  }
  # devtools
  ($RUN_R -e "utils::install.packages('devtools',type='binary',repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'devtools'"
    exit 1
  }
  # fftwtools
  ($RUN_R -e "utils::install.packages('fftwtools',type='binary',repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'fftwtools'"
    exit 1
  }
  # hdf5r
  ($RUN_R -e "utils::install.packages('hdf5r',type='binary',repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'fftwtools'"
    exit 1
  }
  # dipsaus
  ($RUN_R -e "utils::install.packages('dipsaus',type='binary',repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'dipsaus'"
    exit 1
  }
  # threeBrain
  ($RUN_R -e "utils::install.packages('threeBrain',type='binary',repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'threeBrain'"
    exit 1
  }
  
  #
  # install brew if fftw not found
  # /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  
  
  # install RAVE
  $RUN_R -e "remotes::install_github('beauchamplab/rave', upgrade = FALSE, force = TRUE, type = 'binary')"
  $RUN_R -e "remotes::install_github('dipterix/rutabaga@develop', upgrade = FALSE, force = FALSE, quiet = TRUE)"
  $RUN_R -e "remotes::install_github('beauchamplab/ravebuiltins@migrate2', upgrade = FALSE, force = FALSE, quiet = TRUE)"
  
  $RUN_R -e "remotes::install_github('dipterix/dipsaus', upgrade = FALSE, force = TRUE, type = 'binary')"
  $RUN_R -e "remotes::install_github('dipterix/threeBrain', upgrade = FALSE, force = TRUE, type = 'binary')"

fi


clear -x
echo "[RAVE]: Step 3: Download N27 Brain"

install_n27=1
if [ $start_step -gt 1 ]; then
  echo "[RAVE]: skipped"
else
  # check if N27 brain exists
  
  if [ $ALLYES -lt 1 ]; then
    [ -d "$N27_PATH" ] && {
    
      echo "[RAVE]: N27 brain found at '$N27_PATH'"
      while true; do
          read -p "Do you want to re-download it? [Yes/y or No/n]: " yn
          case $yn in
              [Yy]* ) install_n27=1; break;;
              [Nn]* ) install_n27=0; break;;
              * ) echo "Please answer yes or no.";;
          esac
      done
    }
  else
    install_n27=1
  fi
  
  if [ $install_n27 -gt 0 ]; then
    # $RUN_R -e "threeBrain::merge_brain()"
    rm -r "$N27_PATH" 2> /dev/null
    $RUN_R -e "threeBrain::brain_setup(use_python = FALSE)"
    echo ""
  fi
fi

clear -x
echo "[RAVE]: Step 4: Check RAVE settings"
if [ $start_step -gt 2 ]; then
  echo "[RAVE]: skipped"
else
  $RUN_R -e "require(rave); rave::arrange_modules(refresh = TRUE, reset = FALSE)" &> /dev/null
  $RUN_R -e "rave::arrange_data_dir(TRUE, FALSE)" &> /dev/null
  
  # check data_dir
  data_dir=$($RUN_R -e "cat(as.character(rave::rave_options('data_dir')))")
  raw_dir=$($RUN_R -e "cat(as.character(rave::rave_options('raw_data_dir')))")
  
  if [ ! -d "$raw_dir" ]; then
    
    echo "[RAVE]: Cannot find folder to store **raw** data directory ($raw_dir NOT FOUND)"
    while true; do
        read -p "Please enter the path to raw data folder: " -e raw_dir
        raw_dir=$(echo "$raw_dir" | sed "s/~/$HOME_BSLASH/g" | sed "s/\\\\/\\//g")
        if [ -d "$raw_dir" ]; then
          $RUN_R -e "cat(as.character(rave::rave_options('raw_data_dir'='$raw_dir')))" &> /dev/null
          break;
        else
          echo "RAW data path $raw_dir not exists! Please re-enter: "
        fi
    done
  fi
  
  if [ ! -d "$data_dir" ]; then
    echo "[RAVE]: Cannot find RAVE **main** data directory ($data_dir NOT FOUND)"
    while true; do
        read -p "Please enter the path to main data folder: " -e data_dir
        data_dir=$(echo "$data_dir" | sed "s/~/$HOME_BSLASH/g" | sed "s/\\\\/\\//g")
        if [ -d "$data_dir" ]; then
          $RUN_R -e "cat(as.character(rave::rave_options('data_dir'='$data_dir')))" &> /dev/null
          break;
        else
          echo "Main data path $data_dir not exists! Please re-enter: "
        fi
    done
  fi
  
  
  echo "[RAVE]: RAW directory  - $raw_dir"
  echo "[RAVE]: Main directory - $data_dir"
fi

clear -x
echo "[RAVE]: Step 5: Check demo subject(s), modules, and misc.."
if [ $start_step -gt 3 ]; then
  echo "[RAVE]: skipped"
elif [ $ALLYES -lt 1 ]; then
  data_dir=$($RUN_R -e "cat(as.character(normalizePath(rave::rave_options('data_dir'))))")
  echo "[RAVE]: Please select demo subject(s) to download. "
  echo "  Enter the corresponding indices (like 1,2,3), use ',' to separate."
  # check demo subject
  for ii in "${!DEMO_SUBS[@]}"
  do
    sub="${DEMO_SUBS[ $ii ]}"
    subdir="$data_dir/demo/$sub"
    if [ -d "$subdir" ]; then
      echo "  $ii $sub (installed)"
    else
      echo "  $ii $sub"
    fi
  done
  read -p "Please select which subjects to download. Leave it blank to skip: " -e subidx
  
  # get user's input
  $RUN_R -e "demo_subs='$DEMO_SUB_STR';subidx='$subidx';source('https://raw.githubusercontent.com/dipterix/instrave/master/R/demo_install.R', echo = FALSE);"
else
  $($RUN_R -e "rave:::check_dependencies2()")
fi


# echo to ~/rave_module/rave_startup.R
mkdir -p ~/rave_module
echo "# Select a line, use 'command + return' to run that line" > ~/rave_module/rave_startup.R

echo "" >> ~/rave_module/rave_startup.R
echo "# To launch RAVE - main application" >> ~/rave_module/rave_startup.R
echo "rave::start_rave()" >> ~/rave_module/rave_startup.R

echo "" >> ~/rave_module/rave_startup.R
echo "# To open preprocess app" >> ~/rave_module/rave_startup.R
echo "rave::rave_preprocess()" >> ~/rave_module/rave_startup.R

echo "" >> ~/rave_module/rave_startup.R
echo "# To set option" >> ~/rave_module/rave_startup.R
echo "rave::rave_options()" >> ~/rave_module/rave_startup.R

echo "" >> ~/rave_module/rave_startup.R

open -a rstudio ~/rave_module/rave_startup.R


$RUN_R -e "rave::start_rave()"

exit 0

