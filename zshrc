#
# ZShell
#

ZSH="$HOME/.oh-my-zsh"
ZSH_THEME='robbyrussell'

plugins=(git)

export PATH="/usr/local/bin:$PATH"

source "$ZSH/oh-my-zsh.sh"

# Set VIM as default editor
export VISUAL=vim
export EDITOR="${VISUAL}"

# Fuzzy auto-completion
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-z\-}={A-Z\_}' \
  'r:[^[:alpha:]]||[[:alpha:]]=** r:|=* m:{a-z\-}={A-Z\_}' \
  'r:[[:ascii:]]||[[:ascii:]]=** r:|=* m:{a-z\-}={A-Z\_}'

#
# Homebrew
#

# Use brew binaries before system binaries
export PATH="/usr/local/bin:$PATH"
export PATH="/usr/local/sbin:$PATH"

#
# Java
#

if [[ "${OSTYPE}" == darwin* ]]; then
  export JAVA_HOME="$(/usr/libexec/java_home -v 1.8)"
fi

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
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# React packager settings
export REACT_EDITOR='code'

#
# Ruby
#

# rbenv setup
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

#
# Other
#

# Aliases
alias lynx="lynx -cfg=$HOME/.lynxrc"

# thefuck setup
alias fuck='eval $(thefuck $(fc -ln -1 | tail -n 1)); fc -R'

# Android SDK (installed via homebrew)
export ANDROID_HOME=/usr/local/share/android-sdk
export PATH=${PATH}:${ANDROID_HOME}/platform-tools:${ANDROID_HOME}/emulator

# Add depot_tools binaries
export PATH="$HOME/Projects/depot_tools:$PATH"

# Command shortcuts
alias .is="cd ~/Projects/isair"
alias .mj="cd ~/Projects/mojilala-mobile"
alias .fx="cd ~/Projects/fairfx"
alias .ot="cd ~/Projects/other"

alias .gs="git status"
alias .ga="git add"
alias .gap="git add --patch"
alias .gf="git fetch"
alias .gfap="git fetch --all --prune"
alias .gb="git branch"
alias .gba="git branch -a"
alias .gch="git checkout"
alias .grb="git rebase"
alias .grbi="git rebase -i"
alias .gcm="git commit"
alias .gps="git push"
alias .gl="git log --graph"
alias .gla=".gl --all"
alias .glp="git log --graph --full-history --color \
  --pretty=format:'%x1b[31m%h%x09%x1b[32m%d%x1b[0m%x20%s'"
alias .glpa=".glp --all"
alias .gpl="git pull"
alias .gplr="git pull --rebase"
alias .gd="git diff"
alias .gdc="git diff --cached"
alias .gr="git remote"
alias .grup="git remote update --prune"
alias .gsw="git show"
alias .grt="git revert"
alias .gcp="git cherry-pick"
alias .gdm="git branch --merged | egrep -v \"(^\*|master|dev|develop)\" | xargs git branch -d"

alias .bin="bundle install --path=vendor/bundle"
alias .bup="bundle update"
alias .bx="bundle exec"

alias .pin="pod install"
alias .pup="pod update"

alias .ne="PATH=$(npm bin):$PATH"

alias .changelog="git log --no-merges --pretty=format:\"[%an] %s%n%n%b%n-------\""

alias .s="ddgr"
