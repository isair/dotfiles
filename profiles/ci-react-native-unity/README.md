# CI Configuration for React Native + Unity Builds

This is an OS X only profile for use when setting up a CI machine capable of building
and deploying React Native and/or Unity apps.

It assumes that every node package and ruby gem will be installed per-project, and therefore only comes with rbenv and nvm and doesn't have globally installed packages for those platforms nor a strict version of node or ruby.
