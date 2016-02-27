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
alias lynx='lynx -cfg=~/.lynxrc'

# added by travis gem
[ -f /Users/Isair/.travis/travis.sh ] && source /Users/Isair/.travis/travis.sh

# thefuck setup
alias fuck='eval $(thefuck $(fc -ln -1 | tail -n 1)); fc -R'

# nvm setup
export NVM_DIR="/Users/Isair/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Android SDK
export ANDROID_HOME=/usr/local/opt/android-sdk

# React Editor
REACT_EDITOR=atom

# Set atom as default system editor
export VISUAL=atom
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL -w"

# Fuzzy auto-completion
zstyle ':completion:*' matcher-list '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'
