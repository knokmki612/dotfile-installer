# dotfile installer

## What's this?

dotfile-installer helps your dotfiles management. This software focuses no learning cost is required to start using and there is no need to write the setting. All you need is just exec `./install.sh` (or `dotfile-installer`).

Example dotfiles repository: https://github.com/knokmki612/dotfiles

## Essential points

* dotfile-installer was written as a shell script. Possibly no need additional install.
* Can link dotfiles also from more than 2 depth directories
* Please deploy your dotfiles with rename no dot to your dotfiles repository. dotfile-installer will link files with adding dot prefix. (ex. `cp ~/.bash_profile dotfiles/bash_profile`)
* dotfile-installer supports gitmodule directory linking as same as other dotfile. You can separate config as gitmodule of  Emacs, Vim, other high independency software.
* If you want to ignore some local dotfiles, dotfile-installer will add to ~/.dotfileignore. You can choose what you want to manage in dotfiles repository and each environment.

## Installation & Usage

### As a standalone tool (via mise)

Every tagged version is published as a GitHub Release with a single
`dotfile-installer` executable, so [mise](https://mise.jdx.dev/) can install it:

```
$ cd dotfiles
$ mise exec github:knokmki612/dotfile-installer -- dotfile-installer
```

Or pin it in your mise config:

```toml
[tools]
"github:knokmki612/dotfile-installer" = "latest"
```

Without arguments `dotfile-installer` uses the current directory, which must
be the root of a git repository. You can also pass the dotfiles directory
explicitly: `dotfile-installer ~/dotfiles`.

The script has no dependencies besides a POSIX shell, so you can also just
download `install.sh` and run `sh install.sh ~/dotfiles`.

### As a git submodule

```
$ cd dotfiles
$ git submodule add https://github.com/knokmki612/dotfile-installer.git
$ ln -s dotfile-installer/install.sh .
$ ./install.sh
```

When the dotfiles repository contains dotfile-installer as a submodule (with
the `install.sh` symlink), both the submodule and the symlink are skipped,
whichever way the installer is invoked.

## FAQ

### I moved my dotfiles directory. How to ease re-linking dotfiles?

You can use yes command.

```
$ yes | ./install.sh
```

## Releasing

Bump `VERSION` in `install.sh`, then push a tag with the same version (e.g.
`1.3.0`). The Release workflow verifies the version and publishes the
release asset.
