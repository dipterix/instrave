#!/bin/bash

# register global variables

R_VER_MAJOR=3
R_VER_MINOR=6
R_VER_DEV=0
INST_PATH="$HOME/Documents/rave_data/RAVE_install"
N27_PATH="$HOME/Documents/rave_data/others/three_brain/N27/"
HOME_BSLASH=$(echo "$HOME" | sed "s/\//\\\\\\\\/g")
DEMO_SUB_STR="All All_that_are_not_installed KC YAB YAD YAF YAH YAI YAJ YAK"
DEMO_SUBS=( $DEMO_SUB_STR );
RTOOLS_VER="3\.5"
RTOOLS_URL="https://cran.r-project.org/bin/windows/Rtools/Rtools35.exe"


if [ "$#" -ne 1 ]; then
  start_step=0
else
  start_step="$1"
fi


echo $start_step
# exit 0

echo "============ Welcome to RAVE installer (Windows) ============";
echo "[RAVE]: Step 1: check system requirement..."

# Check if R installed or R version is too low
r_need_install=0

if ! [ -x "$(command -v R.exe)" ]; then
  echo "[RAVE]: R is not detected by command - which R"
  r_need_install=1
else	

  r_path=$(which R.exe)
  echo "[RAVE]: R found at $r_path."

  # check R version
  r_version=$(R.exe --version 2>&1 | grep 'R version ' | egrep -o '[0-9]+\.[0-9]+\.[0-9]+')
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


# If r_need_install > 0, need to install latest version of R
if [ $r_need_install -gt 0 ]; then
  # download to ~/Download/RAVE_install
  echo "[RAVE]: Downloading latest version of R from CRAN"
  mkdir -p "$INST_PATH"
  
  curl "https://cran.r-project.org/bin/windows/base/release.htm" > "$INST_PATH/R-version.txt"
  
  RFNAME=$( cat "$INST_PATH/R-version.txt" | egrep -o "R-[0-9.]+-win\.exe" )
  
  echo "Downloading to $INST_PATH/R-latest.exe"
  curl "https://cran.r-project.org/bin/windows/base/$RFNAME" > "$INST_PATH/R-latest.exe"
  
  echo "[RAVE]: Waiting for the installer. Please follow the instructions from the R installer"
  
  "$INST_PATH/R-latest.exe"
  
fi

if [ -d "/c/Rtools" ]; then
  # Check RTools version
  RTV=$(cat "/c/Rtools/VERSION.txt" | egrep -o "$RTOOLS_VER")
  
  if [ -z "$RTV" ]; then
    echo "[RAVE]: Rtools version needs update"
    curl "$RTOOLS_URL" > "$INST_PATH/Rtools.exe"
    "$INST_PATH/Rtools.exe"
  fi
else
 echo "[RAVE]: Rtools version needs update"
  curl "$RTOOLS_URL" > "$INST_PATH/Rtools.exe"
  "$INST_PATH/Rtools.exe"
fi

# install packages for R
echo "[RAVE]: Step 2: Install RAVE and its dependencies"

if [ $start_step -gt 0 ]; then
  echo "[RAVE]: skipped"
else
  # stringr
  (Rscript.exe -e "utils::install.packages('stringr',type='binary',lib=Sys.getenv('R_LIBS_USER'),repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'stringr'"
    exit 1
  }
  # devtools
  (Rscript.exe -e "utils::install.packages('devtools',type='binary',lib=Sys.getenv('R_LIBS_USER'),repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'devtools'"
    exit 1
  }
  # fftwtools
  (Rscript.exe -e "utils::install.packages('fftwtools',type='binary',lib=Sys.getenv('R_LIBS_USER'),repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'fftwtools'"
    exit 1
  }
  # hdf5r
  (Rscript.exe -e "utils::install.packages('hdf5r',type='binary',lib=Sys.getenv('R_LIBS_USER'),repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'fftwtools'"
    exit 1
  }
  # dipsaus
  (Rscript.exe -e "utils::install.packages('dipsaus',type='binary',lib=Sys.getenv('R_LIBS_USER'),repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'dipsaus'"
    exit 1
  }
  # threeBrain
  (Rscript.exe -e "utils::install.packages('threeBrain',type='binary',lib=Sys.getenv('R_LIBS_USER'),repos='https://cloud.r-project.org')") || {
    echo "[RAVE]: Failed to install R package 'threeBrain'"
    exit 1
  }
  
  #
  # install brew if fftw not found
  # /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  
  
  # install RAVE
  Rscript.exe -e "remotes::install_github('beauchamplab/rave', upgrade = FALSE, force = TRUE, type = 'binary')"
  Rscript.exe -e "remotes::install_github('dipterix/rutabaga@develop' upgrade = FALSE, force = FALSE, quiet = TRUE)"
  Rscript.exe -e "remotes::install_github('beauchamplab/ravebuiltins@migrate' upgrade = FALSE, force = FALSE, quiet = TRUE)"

fi

echo "[RAVE]: Step 3: Download N27 Brain"
if [ $start_step -gt 1 ]; then
  echo "[RAVE]: skipped"
else
  # check if N27 brain exists
  install_n27=1
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
  
  if [ $install_n27 -gt 0 ]; then
    # Rscript.exe -e "threeBrain::merge_brain()"
    rm -r "$N27_PATH" 2> /dev/null
    Rscript.exe -e "threeBrain::brain_setup(use_python = FALSE)"
    echo ""
  fi
fi


echo "[RAVE]: Step 4: Check RAVE settings"
if [ $start_step -gt 2 ]; then
  echo "[RAVE]: skipped"
else
  Rscript.exe -e "require(rave); rave::arrange_modules(refresh = TRUE, reset = FALSE)" &> /dev/null
  Rscript.exe -e "rave::arrange_data_dir(TRUE, FALSE)" &> /dev/null
  
  # check data_dir
  data_dir=$(Rscript.exe -e "cat(as.character(rave::rave_options('data_dir')))")
  raw_dir=$(Rscript.exe -e "cat(as.character(rave::rave_options('raw_data_dir')))")
  echo "[RAVE]: RAW directory  - $raw_dir"
  echo "[RAVE]: Main directory - $data_dir"
  
  if [ ! -d "$raw_dir" ] || [ ! -d "$data_dir" ]; then
    echo "Please check existence of RAVE main data and raw data directory"
    Rscript.exe -e "rave::rave_options()" &>/dev/null
  fi
  
fi


echo "[RAVE]: Step 5: Check demo subject(s)"
if [ $start_step -gt 3 ]; then
  echo "[RAVE]: skipped"
else
  data_dir=$(Rscript.exe -e "cat(as.character(normalizePath(rave::rave_options('data_dir'))))")
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
  Rscript.exe -e "demo_subs='$DEMO_SUB_STR';subidx='$subidx';source('https://raw.githubusercontent.com/dipterix/instrave/master/R/demo_install.R', echo = FALSE);"
fi

while true; do
    read -p "[RAVE]: RAVE installed. Want to start application? [Yes/No]: " yn
    case $yn in
        [Yy]* ) Rscript.exe -e "rave::start_rave()"; break;;
        [Nn]* ) break;;
        * ) echo "Please answer Yes/y or No/n.";;
    esac
done











