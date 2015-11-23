ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"

plugins=(git)

export PATH="/usr/local/bin:$PATH"

source $ZSH/oh-my-zsh.sh

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

## Use brew binaries before system binaries.
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# Aliases
alias git=hub

# added by travis gem
[ -f /Users/Isair/.travis/travis.sh ] && source /Users/Isair/.travis/travis.sh

# rbenv setup
export RBENV_ROOT=/usr/local/var/rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# thefuck setup
alias fuck='eval $(thefuck $(fc -ln -1 | tail -n 1)); fc -R'

# nvm setup
export NVM_DIR="/Users/Isair/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Android SDK
export ANDROID_HOME=/usr/local/opt/android-sdk

# React Editor
REACT_EDITOR=mvim
