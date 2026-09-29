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

To simplify instructions, the paths provided in this README are for macOS scripts. However, these all have their counterparts for other OSs. You just need to replace the `macos` part with `linux` or `windows`, or `unix` part with `windows`. Sometimes additional minor changes to the path are required as well but it should all be clear and intuitive.

### Creating a Profile

First, fork this repository and clone it on your machine. Then:

```sh
<project-dir>/scripts/unix/backup.sh <profile-name>
```

This will back-up your packages, apps, and configurations to the profile you've given - `personal` if left blank. Creating the profile as necessary if it doesn't exist.

### Inheriting Profiles

To base a profile on another, add an `inherits` file at the profile root. Put one parent profile name on each line:

```text
# profiles/work/inherits
personal
```

Parents can inherit from other profiles. You can list several parents; each profile is resolved once, with ancestors before descendants and the selected profile last. Packages from every resolved profile are installed. For a configuration present in several profiles, the last file in that order wins. On Unix the chosen files and `~/.config` directories are symlinked to their original profile; on Windows the chosen files are copied. Missing parents, invalid names, and inheritance cycles stop installation before packages or configurations are changed.

Backups write to the selected profile only. Package entries and configuration files identical to an inherited profile are removed from the child's backup, so the parent remains the source for those settings. Windows Scoop exports are reduced in the same way when parent Scoopfiles contain the same app or bucket entries. An `inherits` file is never changed by a backup.

### Installing a Profile

The following steps assume that you are doing the setup on a freshly formatted computer. Therefore you don't even have your SSH keys or anything set up.

Open a terminal and enter the commands below.

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
./scripts/macos/install.sh <profile-name>
```

### Windows

Use a regular PowerShell session (not Run as administrator). Clone the repo, then run:

```powershell
& .\scripts\windows\Backup.ps1 personal
& .\scripts\windows\Install.ps1 personal
```

`Backup.ps1` creates `profiles/<name>` if needed. `Install.ps1` requires an existing profile and installs its Scoop, npm, and Python packages when their manifests exist. If a Scoop manifest is present and Scoop is missing, it uses Scoop's official per-user installer. Scoop backups are stored as `packages/scoopfile.json`, which includes buckets; older `packages/scoop.txt` lists still install. Run the scripts with `powershell.exe -ExecutionPolicy Bypass -File .\scripts\windows\Install.ps1 personal` if local execution policy blocks the file.

Windows configuration backup covers the Windows PowerShell and PowerShell 7 console profiles, `_vimrc`, SSH config, and Hyper config when present. Install copies these files into the active user's locations and saves different existing files as `.pre-dotfiles.bak`; it stops if that backup name is already occupied. Re-run install after editing the profile. The backup leaves absent files and missing package managers' existing manifests untouched.

`Update.ps1` pulls a clean checkout with a fast-forward only and updates Scoop and installed apps. `Cleanup.ps1` removes old Scoop versions and its download cache. `Backup-WindowsKey.ps1` and `Backup-Putty.ps1` are separate, manual backups; they are never run by `Backup.ps1`, and `profiles/**/secure/` is gitignored.

## Automating Backup, Cleanup & Updates

One way to automate backup and cleanup is to add cron jobs for these scripts.

```sh
crontab -e
```

Append the following line, changing the path as necessary.
```sh
0 15 * * * ~/projects/dotfiles/scripts/unix/backup.sh <profile-name>
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

On Unix, dotfiles are symlinked to your project clone directory. The update script also pulls changes from git. On Windows, configuration files are copied; re-run `Install.ps1` to apply profile changes.

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
- pacman
- yay
- yum
- npm
- pip

### Windows

- scoop
- npm
- pip

## Backed-up Configurations

- bash
- zshell
- profile
- hyper.js
- vim
- ssh
- select `~/.config` directories (see `XDG_CONFIG_BACKUP_DIRS` in `scripts/unix/backup.sh`; the whole folder is skipped on purpose since it contains credentials and caches, and installed dependency trees like `node_modules` are pruned via `XDG_CONFIG_EXCLUDES`, leaving manifests/lockfiles intact)

## Development

Commit scopes:
- profiles
- scripts
- repo
