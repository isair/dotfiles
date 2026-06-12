PROFILES_PATH="$(dirname "$0")"/../../profiles

function echoError() {
  cat <<< "Error: $@" 1>&2;
  exit 1
}

function abortIfSudo() {
  if [ "$(id -u)" = 0 ]; then
    echoError "Don't run this script using sudo"
  fi
}

function abortIfProfileNotFound() {
  if [ ! -d "${PROFILE_PATH}" ]; then
    echoError No profile named "${PROFILE}" has been found
  fi
}

function setProfileEnv() {
  DEFAULT_PROFILE=personal
  PROFILE="${1:-$DEFAULT_PROFILE}"
  PROFILES_PATH=../../profiles
  PROFILE_PATH="${PROFILES_PATH}/${PROFILE}"
  PACKAGES_PATH="${PROFILE_PATH}"/packages
  CONFIGS_PATH="${PROFILE_PATH}"/configurations
}

function packagePath() {
  echo "${PROFILES_PATH}"/"${PROFILE}"/packages/"$1".txt
}

function configPath() {
  echo "${PROFILES_PATH}"/"${PROFILE}"/configurations/"$1"
}

function hasConfig() {
  [ -f "$(configPath "$1")" ]
}

function hasPackages() {
  [ -f "$(packagePath "$1")" ]
}

function hasBinary() {
  hash "$1" 2>/dev/null
}

function hasBrewBinary() {
  hasBinary /usr/local/bin/"$1"
}

function isMac() {
  [[ "${OSTYPE}" == darwin* ]]
}

function universalRealPath() {
  if isMac; then
    OURPWD=$PWD
    cd "$(dirname "$1")"
    TARGET="$(basename "$1")"
    # Follow the symlink chain to its final target.
    while [ -L "$TARGET" ]; do
      TARGET="$(readlink "$TARGET")"
      cd "$(dirname "$TARGET")"
      TARGET="$(basename "$TARGET")"
    done
    REALPATH="$PWD/$TARGET"
    cd "$OURPWD"
    echo "$REALPATH"
  else
    realpath "$1"
  fi
}

function getInstallationUser() {
  ls -ld "$(universalRealPath "$0")" | awk '{print $3}'
}
