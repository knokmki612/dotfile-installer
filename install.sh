#!/bin/sh
: <<-LICENSE
	Copyright 2018 knokmki612
	This program is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program.  If not, see <https://www.gnu.org/licenses/>.
LICENSE

VERSION='1.3.0'

usage() {
	cat <<-USAGE
		Usage: dotfile-installer [DOTFILES_DIR]

		Symlink every file in DOTFILES_DIR to ~/.<path>.

		DOTFILES_DIR defaults to:
		  - the directory of the invoking symlink, when run as a symlink to a
		    dotfile-installer git submodule (e.g. ./install.sh)
		  - otherwise the current directory, which must be a git repository root
	USAGE
}

case "$1" in
-h | --help)
	usage
	exit
	;;
-v | --version)
	echo "dotfile-installer $VERSION"
	exit
	;;
-*)
	usage >&2
	exit 1
	;;
esac

echo "dotfile-installer $VERSION"

die() {
	echo "dotfile-installer: $*" >&2
	exit 1
}

gitmodule_paths() {
	[ -f "$1" ] || return 0
	grep 'path' "$1" | cut -d ' ' -f 3-
}

# Whether $1 is a symlink pointing into a git submodule of its own directory,
# i.e. the classic "ln -s dotfile-installer/install.sh ." setup.
is_submodule_link() {
	[ -L "$1" ] || return 1
	module=$(dirname "$(readlink "$1")")
	[ '.' != "$module" ] &&
		gitmodule_paths "$(dirname "$1")/.gitmodules" | grep -qxF "$module"
}

script=$0
while [ -L "$script" ]; do
	target=$(readlink "$script")
	case "$target" in
	/*) script=$target ;;
	*) script=$(dirname "$script")/$target ;;
	esac
done
SCRIPT_DIR=$(cd "$(dirname "$script")" && pwd -P)

if [ -n "$1" ]; then
	DOTFILES_DIR=$(cd "$1" && pwd) || die "no such directory: $1"
elif is_submodule_link "$0"; then
	DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
else
	DOTFILES_DIR=$(pwd)
	[ -e "$DOTFILES_DIR/.git" ] ||
		die "$DOTFILES_DIR is not a git repository root; pass DOTFILES_DIR explicitly"
fi
cd "$DOTFILES_DIR" || exit
DOTFILES_IGNOREFILE="$HOME/.dotfileignore"

[ "$(pwd -P)" = "$(cd "$HOME" && pwd -P)" ] && die 'refusing to use the home directory as DOTFILES_DIR'
[ "$(pwd -P)" = "$SCRIPT_DIR" ] && die 'refusing to install dotfile-installer itself'

# When the repository still carries the installer as a submodule, skip the
# submodule and its entry point symlink.
SELF_LINK=
SELF_MODULE=
for link in "$(basename "$0")" install.sh; do
	is_submodule_link "$link" && {
		SELF_LINK=$link
		SELF_MODULE=$(dirname "$(readlink "$link")")
		break
	}
done

GITMODULES=$(gitmodule_paths .gitmodules)

ignores="$GITMODULES
.git
$SELF_LINK
LICENSE
README"
ignores_from_ignorefile=
[ -f "$DOTFILES_IGNOREFILE" ] && {
	ignores_from_ignorefile="$(cat "$DOTFILES_IGNOREFILE")"
	ignores=$(printf '%s\n%s' "$ignores" "$ignores_from_ignorefile")
}

generate_ignore_patterns() {
	patterns=$(echo "$1" | grep -v '^$')
	[ -z "$patterns" ] && return
	echo "$patterns" |
		awk '{
		gsub(/[. \/]/, "\\\\&")
		print "!/^" $0 "/"
	}' |
		awk -v final="$(echo "$patterns" | wc -l)" '{
		if (NR!=final) sub(/$/, " \\&\\& \\")
		print $0
	}'
}

dotfiles=$(
	find -L . -type f |
		cut -d '/' -f 2- |
		awk "$(generate_ignore_patterns "$ignores") { print \$0 }"
)
dotdirs=$(
	echo "$GITMODULES" |
		grep -vxF "$SELF_MODULE" |
		awk "$(generate_ignore_patterns "$ignores_from_ignorefile") { print \$0 }"
)
dots="$dotdirs
$dotfiles"

echo "$dots" |
	awk -v home="$HOME" '{
	sub(/^/, home "/.")
	print $0
}' |
	tr '\n' '\0' |
	xargs -0 -n1 dirname |
	grep -v "$HOME$" |
	uniq |
	tr '\n' '\0' |
	xargs -0 mkdir -p

IFS='
'

dialog() {
	ln -insv "$target" "$link_name"
	[ "$target" = "$(readlink "$link_name")" ] || {
		echo "$dot" >>"$DOTFILES_IGNOREFILE"
	}
}

for dot in $dots; do
	target="$DOTFILES_DIR/$dot"
	link_name="$HOME/.$dot"
	entity=$(readlink "$link_name")
	[ "$target" = "$entity" ] && continue # already linked
	[ -L "$link_name" ] && { [ ! -f "$entity" ] || [ ! -d "$entity" ]; } && {
		# broken symlink
		dialog
		continue
	}
	[ -f "$link_name" ] && { # not yet linked but file already exists
		diff -su "$link_name" "$target"
		dialog
		continue
	}
	[ -d "$link_name" ] && continue # not yet linked but dir already exists
	ln -nsv "$target" "$link_name"  # not yet linked and no exists
done
