#
# ZShell
#

ZSH="$HOME/.oh-my-zsh"
ZSH_THEME='robbyrussell'

plugins=(git)

export PATH="/usr/local/bin:$PATH"

source "$ZSH/oh-my-zsh.sh"

# Fuzzy auto-completion
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'

#
# Rust
#

## Add rust packages
export PATH="$HOME/.cargo/bin:$PATH"

# Racer setup
export RUST_SRC_PATH="$HOME/Projects/other/rustc-1.6.0/src/"

#
# JavaScript
#

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

# React packager settings
REACT_EDITOR='atom'

#
# Ruby
#

# travis gem setup
[ -f "$HOME/.travis/travis.sh" ] && source "$HOME/.travis/travis.sh"

#
# Other
#

# Aliases
alias git=hub
alias lynx="lynx -cfg=$HOME/.lynxrc"

# Heroku Toolbelt setup
export PATH="/usr/local/heroku/bin:$PATH"

# Use brew binaries before system binaries
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

# thefuck setup
alias fuck='eval $(thefuck $(fc -ln -1 | tail -n 1)); fc -R'

# Android SDK (installed via homebrew)
export ANDROID_HOME='/usr/local/opt/android-sdk'

# Add depot_tools binaries
export PATH="$HOME/Projects/depot_tools:$PATH"

# Add binaries in Dropbox
export PATH="$HOME/Dropbox/bin:$PATH"
