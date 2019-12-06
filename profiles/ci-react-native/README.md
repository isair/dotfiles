# CI Configuration for React Native

This is an OS X only profile for use when setting up a CI machine capable of building and deploying React Native apps using Jenkins.

It assumes that every node package and ruby gem will be installed per-project, and therefore only comes with chruby and nvm and doesn't have globally installed packages for those platforms nor a strict version of node or ruby.

# Getting Started

Clone this repo under `~/projects/`, `cd` in the project directory, and:
```sh
./scripts/osx/install.sh ci-react-native
```

Next add the following lines to your cron jobs via `crontab -e`:
```
0 15 * * * ~/projects/dotfiles/scripts/osx/backup.sh
```

Then add the following to your admin cron jobs via `sudo crontab -e`:
```
30 9 * * * /home/owner/projects/dotfiles/scripts/ubuntu/cleanup.sh
```

Launch `Android Studio` and install Android SDK using the recommended options, accept any licenses.

Launch `Xcode` and accept any agreements.

You can now open the browser on your CI machine or VM and go to `https://localhost:8080` to set up Jenkins. I recommend using the `Code as Configuration` plugin so you can set workflows via a config file in you repo(s).