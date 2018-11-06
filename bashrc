# Launch Zsh
if [[ "${OSTYPE}" == darwin* ]]; then
  # Only on OS X. Causes eternal loops with some linux desktop envs.
  exec zsh
fi
