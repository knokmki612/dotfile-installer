# dotfile installer

## What's this?

dotfile-installer helps your dotfiles management. This software focuses no learning cost is required to start using and there is no need to write the setting. All you need is just exec `./install.sh`.

Example dotfiles repository: https://github.com/knokmki612/dotfiles

## Essential points

* dotfile-installer was written as a shell script. Possibly no need additional install.
* Can link dotfiles also from more than 2 depth directories
* Please deploy your dotfiles with rename no dot to your dotfiles repository. dotfile-installer will link files with adding dot prefix. (ex. `cp ~/.bash_profile dotfiles/bash_profile`)
* dotfile-installer supports gitmodule directory linking as same as other dotfile. You can separate config as gitmodule of  Emacs, Vim, other high independency software.
* If you want to ignore some local dotfiles, dotfile-installer will add to ~/.dotfileignore. You can choose what you want to manage in dotfiles repository and each environment.
* dotfile-installer automatically installs git-hook script. hook will works at `git pull`

## Installation & Usage

```
$ cd dotfiles
$ git submodule add https://github.com/knokmki612/dotfile-installer.git
$ ln -s dotfile-installer/install.sh .
$ ./install.sh
```

## FAQ

### I moved my dotfiles directory. How to ease re-linking dotfiles?

You can use yes command.

```
$ yes | ./install.sh
```
