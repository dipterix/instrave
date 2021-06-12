
cd /Users/dipterix/Dropbox/projects/instrave/brew

# brew create --cask --set-name rave https://github.com/dipterix/instrave/archive/refs/tags/0.0.2.tar.gz

brew create --set-name rave-m1 https://github.com/beauchamplab/rave/archive/refs/tags/v0.1.9-beta.tar.gz

brew create --cask --set-name r-m1 https://cran.r-project.org/bin/macosx/big-sur-arm64/base/R-4.1.0-arm64.pkg

export HOMEBREW_NO_AUTO_UPDATE=1

rm /opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/rave.rb
arch -arm64 brew install --verbose --debug --build-from-source -i rave

brew install gcc

Rscript --no-save "install-rave.R"

brew install --cask -i rave-m1

/opt/homebrew/Library/Taps/homebrew/homebrew-cask/Casks/rave.rb

sha256 "77dcf288dc4198ba32359fe5fc2a79303ba7bc960033086ff7856dcc318ce953"

brew create --set-name rave https://github.com/beauchamplab/rave/archive/refs/tags/v0.1.9-beta.tar.gz
/opt/homebrew/Library/Taps/homebrew/homebrew-core/Formula/rave.rb
