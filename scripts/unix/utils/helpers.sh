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
  validateProfileName "${PROFILE}"
  PROFILES_PATH=../../profiles
  PROFILE_PATH="${PROFILES_PATH}/${PROFILE}"
  PACKAGES_PATH="${PROFILE_PATH}"/packages
  CONFIGS_PATH="${PROFILE_PATH}"/configurations
}

function validateProfileName() {
  if [[ ! "$1" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || [ "$1" = . ] || [ "$1" = .. ]; then
    echoError "Invalid profile name: $1"
  fi
}

# Resolve parents before children. Each non-comment line in `inherits` names a
# parent profile; later parents and the selected profile take precedence.
function resolveProfileChain() {
  PROFILE_CHAIN=()
  PROFILE_VISITING=()
  _resolveProfile "${PROFILE}"
}

function _resolveProfile() {
  local name="$1" parent entry
  validateProfileName "${name}"
  for entry in "${PROFILE_VISITING[@]+"${PROFILE_VISITING[@]}"}"; do
    [ "${entry}" = "${name}" ] && echoError "Profile inheritance cycle at ${name}"
  done
  for entry in "${PROFILE_CHAIN[@]+"${PROFILE_CHAIN[@]}"}"; do
    [ "${entry}" = "${name}" ] && return 0
  done
  [ -d "${PROFILES_PATH}/${name}" ] || echoError "No profile named ${name} has been found"
  PROFILE_VISITING+=("${name}")
  if [ -f "${PROFILES_PATH}/${name}/inherits" ]; then
    while IFS= read -r parent || [ -n "${parent}" ]; do
      parent="${parent%%#*}"
      parent="$(printf '%s' "${parent}" | tr -d '[:space:]')"
      [ -n "${parent}" ] || continue
      _resolveProfile "${parent}"
    done < "${PROFILES_PATH}/${name}/inherits"
  fi
  unset "PROFILE_VISITING[$((${#PROFILE_VISITING[@]} - 1))]"
  PROFILE_CHAIN+=("${name}")
}

function packagePaths() {
  PACKAGE_FILES=()
  local name path
  for name in "${PROFILE_CHAIN[@]}"; do
    path="${PROFILES_PATH}/${name}/packages/$1.txt"
    [ -s "${path}" ] && PACKAGE_FILES+=("${path}")
  done
}

function readPackageNames() {
  PACKAGES=()
  local package
  while IFS= read -r package || [ -n "${package}" ]; do
    [ -n "${package}" ] && PACKAGES+=("${package}")
  done < "$1"
  return 0
}

function packagePath() {
  echo "${PROFILES_PATH}"/"${PROFILE}"/packages/"$1".txt
}

function configPath() {
  local name path selected=""
  for name in "${PROFILE_CHAIN[@]}"; do
    path="${PROFILES_PATH}/${name}/configurations/$1"
    [ -f "${path}" ] && selected="${path}"
  done
  printf '%s\n' "${selected}"
}

function hasConfig() {
  [ -f "$(configPath "$1")" ]
}

function hasPackages() {
  packagePaths "$1"
  [ -n "${PACKAGE_FILES[*]-}" ]
}

function pruneInheritedPackages() {
  local manifest="${PACKAGES_PATH}/$1.txt" name inherited line output duplicate
  [ -f "${manifest}" ] || return 0
  output="$(mktemp "${manifest}.XXXXXX")"
  while IFS= read -r line || [ -n "${line}" ]; do
    duplicate=0
    for name in "${PROFILE_CHAIN[@]}"; do
      [ "${name}" = "${PROFILE}" ] && break
      inherited="${PROFILES_PATH}/${name}/packages/$1.txt"
      if [ -f "${inherited}" ] && grep -Fxq -- "${line}" "${inherited}"; then
        duplicate=1
        break
      fi
    done
    [ "${duplicate}" = 1 ] || printf '%s\n' "${line}" >> "${output}"
  done < "${manifest}"
  mv "${output}" "${manifest}"
}

function pruneInheritedConfig() {
  local child="${CONFIGS_PATH}/$1" name inherited="" path
  [ -f "${child}" ] || return 0
  for name in "${PROFILE_CHAIN[@]}"; do
    [ "${name}" = "${PROFILE}" ] && break
    path="${PROFILES_PATH}/${name}/configurations/$1"
    [ -f "${path}" ] && inherited="${path}"
  done
  if [ -n "${inherited}" ] && cmp -s "${child}" "${inherited}"; then
    rm "${child}"
  fi
}

function pruneInheritedConfigDir() {
  local child="${CONFIGS_PATH}/config/$1" name inherited="" path
  [ -d "${child}" ] || return 0
  for name in "${PROFILE_CHAIN[@]}"; do
    [ "${name}" = "${PROFILE}" ] && break
    path="${PROFILES_PATH}/${name}/configurations/config/$1"
    [ -d "${path}" ] && inherited="${path}"
  done
  if [ -n "${inherited}" ] && diff -qr "${child}" "${inherited}" > /dev/null; then
    rm -rf "${child}"
  fi
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
