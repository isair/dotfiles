ZSH="$HOME/.oh-my-zsh"
ZSH_THEME='robbyrussell'

plugins=(git)

export PATH="/usr/local/bin:$PATH"

source "$ZSH/oh-my-zsh.sh"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

## Use brew binaries before system binaries.
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# Aliases
alias git=hub
alias lynx='lynx -cfg=~/.lynxrc'

# travis gem setup
[ -f '~/.travis/travis.sh' ] && source '~/.travis/travis.sh'

# thefuck setup
alias fuck='eval $(thefuck $(fc -ln -1 | tail -n 1)); fc -R'

# nvm setup
export NVM_DIR='~/.nvm'
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# Android SDK (installed via homebrew)
export ANDROID_HOME='/usr/local/opt/android-sdk'

# React Editor
REACT_EDITOR='atom'

# Add depot_tools binaries
export PATH="~/Projects/depot_tools:$PATH"

# Add binaries in Dropbox
export PATH="~/Dropbox/1337/bin:$PATH"

# Set atom as default system editor
export VISUAL='atom'
export EDITOR="$VISUAL"
export GIT_EDITOR="$VISUAL -w"

# Fuzzy auto-completion
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'
