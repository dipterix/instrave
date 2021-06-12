export HOMEBREW_NO_AUTO_UPDATE=1

brew create --tap=dipterix/cask --cask --set-name r-arm https://cran.r-project.org/bin/macosx/big-sur-arm64/base/R-4.1.0-arm64.pkg
brew create --tap=dipterix/cask --cask --set-name rave-arm https://github.com/dipterix/instrave/archive/refs/tags/0.0.3.tar.gz

brew create --tap=dipterix/cask --cask --set-name r-arm-gfortran https://mac.r-project.org/libs-arm64/gfortran-f51f1da0-darwin20.0-arm64.tar.gz
brew install --cask rave-arm

/usr/bin/env PATH=/opt/homebrew/bin:/opt/homebrew/sbin:$PATH Rscript --no-save -e "$(curl -fsSL https://raw.githubusercontent.com/dipterix/instrave/master/brew/install-rave.R)"

brew edit --cask rave-m1
open -e /opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/rave-m1.rb
open -e /opt/homebrew/Library/Taps/dipterix/homebrew-cask/Casks/r-arm.rb
open -e /opt/homebrew/Library/Taps/dipterix/homebrew-cask/Casks/rave-arm.rb
open -e /opt/homebrew/Library/Taps/dipterix/homebrew-cask/Casks/r-arm-gfortran.rb

/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/rave.rb

/usr/bin/env PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/Library/Homebrew/shims/scm:/usr/bin:/bin:/usr/sbin:/sbin Rscript --no-save install-rave.R

sha256 "77dcf288dc4198ba32359fe5fc2a79303ba7bc960033086ff7856dcc318ce953"

brew create --set-name rave https://github.com/beauchamplab/rave/archive/refs/tags/v0.1.9-beta.tar.gz
/opt/homebrew/Library/Taps/homebrew/homebrew-core/Formula/rave.rb
