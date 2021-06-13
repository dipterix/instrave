#!/bin/bash
set -u

# Add additional recipes
# Requirement: sudo

abort() {
  printf "%s\n" "$@"
  exit 1
}

# string formatters
if [[ -t 1 ]]; then
  tty_escape() { printf "\033[%sm" "$1"; }
else
  tty_escape() { :; }
fi
tty_mkbold() { tty_escape "1;$1"; }
tty_underline="$(tty_escape "4;39")"
tty_blue="$(tty_mkbold 34)"
tty_red="$(tty_mkbold 31)"
tty_bold="$(tty_mkbold 39)"
tty_reset="$(tty_escape 0)"

shell_join() {
  local arg
  printf "%s" "$1"
  shift
  for arg in "$@"; do
    printf " "
    printf "%s" "${arg// /\ }"
  done
}

chomp() {
  printf "%s" "${1/"$'\n'"/}"
}

ohai() {
  printf "${tty_blue}==>${tty_bold} %s${tty_reset}\n" "$(shell_join "$@")"
}

have_sudo_access() {
  local -a args
  if [[ -n "${SUDO_ASKPASS-}" ]]; then
    args=("-A")
  elif [[ -n "${NONINTERACTIVE-}" ]]; then
    args=("-n")
  fi

  if [[ -z "${HAVE_SUDO_ACCESS-}" ]]; then
    if [[ -n "${args[*]-}" ]]; then
      SUDO="/usr/bin/sudo ${args[*]}"
    else
      SUDO="/usr/bin/sudo"
    fi
    if [[ -n "${NONINTERACTIVE-}" ]]; then
      ${SUDO} -l mkdir &>/dev/null
    else
      ${SUDO} -v && ${SUDO} -l mkdir &>/dev/null
    fi
    HAVE_SUDO_ACCESS="$?"
  fi

  if [[ -z "${HOMEBREW_ON_LINUX-}" ]] && [[ "$HAVE_SUDO_ACCESS" -ne 0 ]]; then
    abort "Need sudo access on macOS (e.g. the user $USER needs to be an Administrator)!"
  fi

  return "$HAVE_SUDO_ACCESS"
}

execute() {
  if ! "$@"; then
    abort "$(printf "Failed during: %s" "$(shell_join "$@")")"
  fi
}

execute_sudo() {
  local -a args=("$@")
  if have_sudo_access; then
    if [[ -n "${SUDO_ASKPASS-}" ]]; then
      args=("-A" "${args[@]}")
    fi
    ohai "/usr/bin/sudo" "${args[@]}"
    execute "/usr/bin/sudo" "${args[@]}"
  else
    ohai "${args[@]}"
    execute "${args[@]}"
  fi
}

echo "Please enter your password. "
have_sudo_access true

UNAME_MACHINE="$(/usr/bin/uname -m)"

if [[ "$UNAME_MACHINE" == "arm64" ]]; then
  # On ARM macOS, this script installs to /opt/homebrew only
  HOMEBREW_PREFIX="/opt/homebrew"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"
else
  # On Intel macOS, this script installs to /usr/local only
  HOMEBREW_PREFIX="/usr/local"
  HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}/Homebrew"
fi


# Install brew
execute_sudo echo | /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add brew to zsh (z-shell), bash, and sh
# execute echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >> "$HOME/.zprofile"
# execute echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >> "$HOME/.bash_profile"
# execute echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"" >> "$HOME/.profile"
# Activate brew
execute eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"

execute $HOMEBREW_PREFIX/bin/brew install hdf5 fftw libgit2 libxml2 pkg-config


/usr/bin/env PATH=$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH

if [[ "$UNAME_MACHINE" == "arm64" ]]; then
  execute $HOMEBREW_PREFIX/bin/brew tap dipterix/cask
  
  execute $HOMEBREW_PREFIX/bin/brew install --cask r-arm
  
  cd /tmp
  gcc_fname="gfortran-f51f1da0-darwin20.0-arm64.tar.gz"
  curl -O https://mac.r-project.org/libs-arm64/$gcc_fname
  execute_sudo tar fvxz "$gcc_fname" -C /
  execute_sudo rm "$gcc_fname"
else
  execute $HOMEBREW_PREFIX/bin/brew install --cask r
fi



# Check if rstudio exists, if so, update to the newest
if $HOMEBREW_PREFIX/bin/brew ls --cask rstudio > /dev/null; then
  # The package is installed
  echo "RStudio has been installed by brew"
  execute $HOMEBREW_PREFIX/bin/brew remove --cask rstudio
else
  # The package is not installed
  echo "Nah"
  rs_path=/Applications/RStudio.app
  if [[ -d "$rs_path" ]]
  then
    execute_sudo rm -r "$rs_path"
  fi
fi

execute $HOMEBREW_PREFIX/bin/brew install --cask rstudio

# R has been installed
/usr/bin/env PATH=$HOMEBREW_PREFIX/bin:$HOMEBREW_PREFIX/sbin:$PATH Rscript --no-save -e "$(curl -fsSL https://raw.githubusercontent.com/dipterix/instrave/master/brew/install-rave.R)"


