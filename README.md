# dotfiles

Easily set up a new computer, restore your configurations and files, and keep your computer automatically maintained and backed up! Complete with bonus convenience scripts and sensible defaults.

## Setting Up After a Fresh Install

The following steps assume that you are doing the setup on a freshly formatted computer. Therefore you don't even have your SSH keys or anything set up.

### Ubuntu & OS X

Open the Terminal app and enter the commands below.

```
mkdir ~/Projects
cd ~/Projects
git clone https://github.com/isair/dotfiles.git
cd dotfiles
```

Before typing the following line, make sure you check the files under the `data` folder and modify them to personalise your setup.

For Ubuntu:
```
./scripts/ubuntu/install.sh
```

For OS X:
```
./scripts/osx/install.sh
```

### Automating Backup & Cleanup

One way to automate backup and cleanup is to add cron jobs for these scripts.

```
crontab -e
```

Append the following line, changing the path as necessary.
```
0 15 * * * ~/projects/dotfiles/scripts/ubuntu/backup.sh
```

This will update your package list but you'll still need to commit and push yourself, or write a script for it.

```
sudo crontab -e
```

Append the following line, changing the path if needed again.
```
30 9 * * * /users/owner/projects/dotfiles/scripts/ubuntu/cleanup.sh
```
