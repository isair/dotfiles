[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"

## For oh-my-zsh.
export LANG=en_US:UTF-8

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"

## Use brew binaries before system binaries.
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

## Use homebrew installed ruby's gems.
export PATH=/usr/local/opt/ruby/bin:$PATH

# Hub aliasing
alias git=hub

# Docker
export DOCKER_HOST=tcp://192.168.59.103:2375

