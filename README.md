# dotfiles

[![Gitter chat](https://img.shields.io/gitter/room/isair/dotfiles?style=flat-square)](https://gitter.im/isair/dotfiles)
![GitHub last commit](https://img.shields.io/github/last-commit/isair/dotfiles?style=flat-square)

Backup your packages, apps, and configurations directly to git in the form of profiles. Set up any new (virtual) machine using a profile in one line. Share profiles between multiple machines. Configure auto update, clean-up, and back-up. Works for all linux flavors, Mac OS, and Windows.

All installation and backup scripts require you to pass a profile name as their first argument. If you provide no profile name to a script, they'll use the default `personal` profile.

Example use:
```sh
# Set up your new machine quickly using a profile
install.sh <profile-name>
# Assume you're customising your installation here by installing new packages, editing shell configuration, etc
backup.sh <profile-name>
# Now if you're working on your own fork, you can commit this profile and later use it to set up new machines or make reinstallations way easier!
```

## Getting Started

To simplify instructions, the paths provided in this README are for macOS scripts. However, these all have their counterparts for other OSs. You just need to replace the 'osx' part with `linux` or `windows`. Sometimes additional minor changes to the path are required as well but it should all be clear and intuitive.

### Creating a Profile

First, fork this repository and clone it on your machine. Then:

```sh
<project-dir>/scripts/osx/backup.sh <profile-name>
```

This will back-up your packages and apps to the profile you've given - `personal` if left blank. Creating the profile as necessary if it doesn't exist.

The next step is to symlink your configuration files so that any changes to them are picked up by git. You will only need to do this once.

```sh
# Run the lines that apply to your setup
cp ~/.bashrc <project-dir>/profiles/<profile-name>/configurations/bashrc
cp ~/.zshrc <project-dir>/profiles/<profile-name>/configurations/zshrc
cp ~/.vimrc <project-dir>/profiles/<profile-name>/configurations/vimrc
# Then run the following line to symlink these files.
<project-dir>/scripts/unix/symlink-dotfiles.sh <profile-name>
```

### Installing a Profile

The following steps assume that you are doing the setup on a freshly formatted computer. Therefore you don't even have your SSH keys or anything set up.

Open the Terminal app and enter the commands below.

```sh
mkdir ~/projects
cd ~/projects
# It's recommended to use your own fork so you can commit your profile changes later on.
git clone https://github.com/isair/dotfiles.git
cd dotfiles
```

If your setup does not come with `git`, download this project from its GitHub page instead. Later on, the profile you install will most likely have `git`.

Before typing the following line, make sure you check the various profiles under the `profiles` directory and pick one that suits your needs.

```sh
./scripts/osx/install.sh <profile-name>
```

## Automating Backup, Cleanup & Updates

One way to automate backup and cleanup is to add cron jobs for these scripts.

```sh
crontab -e
```

Append the following line, changing the path as necessary.
```sh
0 15 * * * ~/projects/dotfiles/scripts/osx/backup.sh
```

This will update your package list but you'll still need to commit and push yourself, or write a script for it.

```sh
sudo crontab -e
```

Append the following line, changing the path again as needed.
```sh
00 8 * * * /home/owner/projects/dotfiles/scripts/unix/update.sh
00 9 * * * /home/owner/projects/dotfiles/scripts/unix/cleanup.sh
```

Your computer will now update everything and clean-up disk space in the morning. At 15:00, it will do backups.

## Sharing Profiles Between Machines

All dot files are symlinked to your project clone directory. The update script is also responsible for `git pull`ing any changes made to the repo. Therefore, if you have set up automatic updates as mentioned in the previous section, all you need to do is `git push` your changes! Any machine installed using the same profile will automatically get them when their update script runs again.

## Supported Package Managers

The back-up scripts support the following package managers.

### OS X

- brew
- brew cask
- npm
- pip

### Linux

- brew
- apt
- snap
- npm
- pip

### Windows

- scoop

## Backed-up Configurations

- bash
- zshell
- hyper.js
- vim

## Development

Commit scopes:
- profiles
- scripts
- repo
