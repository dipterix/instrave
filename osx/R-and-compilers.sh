#!/bin/sh

# check install xcode command line
( (
  xcode-select --install 2>/dev/null
) && {
  clear -x
  echo "Please install xcode command-line tool in the newly opened window"
} ) || {
  echo "Xcode command line tools are already installed (skip)"
}

echo ""


# Install latest R

INST_PATH=$(mktemp -d -t "rave-installer")

# download to ~/Download/RAVE_install
echo "Downloading latest version of R from CRAN ==> "
echo "       $INST_PATH/R-release.pkg"
echo "(Please wait...)"
mkdir -p "$INST_PATH"
curl "https://cran.r-project.org/bin/macosx/base/R-release.pkg" > "$INST_PATH/R-latest.pkg"

echo "Finished downloading. Installing the latest R..."

installer -pkg "$INST_PATH/R-latest.pkg" -target "/usr/local/bin"

rm -rf "$INST_PATH"

echo "Done. Please close this window"
