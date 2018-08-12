# dotfile installer

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
