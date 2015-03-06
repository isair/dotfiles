ZSH=$HOME/.oh-my-zsh
ZSH_THEME="robbyrussell"

plugins=(git)

export PATH="/usr/local/bin:$PATH"

source $ZSH/oh-my-zsh.sh

[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

## Use brew binaries before system binaries.
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# Hub aliasing
alias git=hub

# added by travis gem
[ -f /Users/Isair/.travis/travis.sh ] && source /Users/Isair/.travis/travis.sh

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
