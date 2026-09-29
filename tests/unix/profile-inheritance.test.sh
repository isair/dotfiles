#!/usr/bin/env bash

set -eu

repo="$(cd "$(dirname "$0")/../.." && pwd)"
fixture="$(mktemp -d)"
fixture="$(cd "${fixture}" && pwd -P)"
trap 'rm -rf "${fixture}"' EXIT

mkdir -p "${fixture}"/{profiles,scripts/unix/utils,home}
cp "${repo}/scripts/unix/symlink-dotfiles.sh" "${fixture}/scripts/unix/"
cp "${repo}/scripts/unix/utils/helpers.sh" "${fixture}/scripts/unix/utils/"
mkdir -p "${fixture}/profiles"/{base,second,child}/{packages,configurations}
printf 'base\n' > "${fixture}/profiles/second/inherits"
printf 'base\nsecond\n' > "${fixture}/profiles/child/inherits"
printf 'brew-base\n' > "${fixture}/profiles/base/packages/brew.txt"
printf 'brew-child\n' > "${fixture}/profiles/child/packages/brew.txt"
printf 'base\n' > "${fixture}/profiles/base/configurations/bashrc"
printf 'child\n' > "${fixture}/profiles/child/configurations/bashrc"
printf 'parent zsh\n' > "${fixture}/profiles/second/configurations/zshrc"

cd "${fixture}/scripts/unix"
source ./utils/helpers.sh
setProfileEnv child
resolveProfileChain
[[ "${PROFILE_CHAIN[*]}" = 'base second child' ]]
hasPackages brew
[[ "${#PACKAGE_FILES[@]}" = 2 ]]
[[ "$(configPath bashrc)" = '../../profiles/child/configurations/bashrc' ]]
[[ "$(configPath zshrc)" = '../../profiles/second/configurations/zshrc' ]]

printf 'brew-base\nbrew-child\n' > "${PACKAGES_PATH}/brew.txt"
pruneInheritedPackages brew
[[ "$(cat "${PACKAGES_PATH}/brew.txt")" = 'brew-child' ]]
printf 'base\n' > "${CONFIGS_PATH}/vimrc"
printf 'base\n' > "${fixture}/profiles/base/configurations/vimrc"
pruneInheritedConfig vimrc
[[ ! -e "${CONFIGS_PATH}/vimrc" ]]
mkdir -p "${CONFIGS_PATH}/config/nvim" "${fixture}/profiles/base/configurations/config/nvim"
printf 'shared\n' > "${CONFIGS_PATH}/config/nvim/init.vim"
printf 'shared\n' > "${fixture}/profiles/base/configurations/config/nvim/init.vim"
pruneInheritedConfigDir nvim
[[ ! -d "${CONFIGS_PATH}/config/nvim" ]]

HOME="${fixture}/home" ./symlink-dotfiles.sh child
[[ "$(readlink "${fixture}/home/.bashrc")" = "${fixture}/profiles/child/configurations/bashrc" ]]
[[ "$(readlink "${fixture}/home/.zshrc")" = "${fixture}/profiles/second/configurations/zshrc" ]]

printf 'child\n' > "${fixture}/profiles/base/inherits"
if (resolveProfileChain 2>/dev/null); then
  echo 'Cycle was accepted' >&2
  exit 1
fi
printf 'missing\n' > "${fixture}/profiles/base/inherits"
if (resolveProfileChain 2>/dev/null); then
  echo 'Missing parent was accepted' >&2
  exit 1
fi
printf '../escape\n' > "${fixture}/profiles/base/inherits"
if (resolveProfileChain 2>/dev/null); then
  echo 'Invalid parent name was accepted' >&2
  exit 1
fi

echo 'Unix profile inheritance checks passed.'
