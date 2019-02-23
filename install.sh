#!/bin/sh
: <<- LICENSE
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

echo 'dotfile-installer 1.1.0'

DOTFILES_DIR=$(cd "$(dirname "$0")" && pwd)
cd "$DOTFILES_DIR" || exit
DOTFILES_IGNOREFILE="$HOME/.dotfileignore"

SELF_MODULE=$(dirname "$(readlink "$(basename "$0")")")
[ '.' = "$SELF_MODULE" ] && exit

GITMODULES=$(grep 'path' .gitmodules | cut -d ' ' -f 3-)

ignores="$GITMODULES
.git
$(basename "$0")
LICENSE
README"
[ -f "$DOTFILES_IGNOREFILE" ] && {
	ignores_from_ignorefile="$(cat "$DOTFILES_IGNOREFILE")"
	ignores=$(printf '%s\n%s' "$ignores" "$ignores_from_ignorefile")
}

generate_ignore_patterns() {
	[ -z "$1" ] && return
	echo "$1" |
	awk '{
		gsub(/[. \/]/, "\\\\&")
		print "!/^" $0 "/"
	}'        |
	awk -v final="$(echo "$1" | wc -l)" '{
		if (NR!=final) sub(/$/, " \\&\\& \\")
		print $0
	}'
}

dotfiles=$(
	find -L . -type f |
	cut -d '/' -f 2-  |
	awk "$(generate_ignore_patterns "$ignores") { print \$0 }"
)
dotdirs=$(
	echo "$GITMODULES"     |
	grep -v "$SELF_MODULE" |
	awk "$(generate_ignore_patterns "$ignores_from_ignorefile") { print \$0 }"
)
dots="$dotdirs
$dotfiles"

echo "$dots"         |
awk -v home="$HOME" '{
	sub(/^/, home "/.")
	print $0
}'                   |
tr '\n' '\0'         |
xargs -0 -n1 dirname |
grep -v "$HOME$"     |
uniq                 |
tr '\n' '\0'         |
xargs -0 mkdir -p

IFS='
'

dialog() {
	ln -insv "$target" "$link_name"
	[ "$target" = "$(readlink "$link_name")" ] || {
		echo "$dot" >> "$DOTFILES_IGNOREFILE"
	}
}

for dot in $dots
do
	target="$DOTFILES_DIR/$dot"
	link_name="$HOME/.$dot"
	entity=$(readlink "$link_name")
	[ "$target" = "$entity" ] && continue # already linked
	[ -L "$link_name" ] && ([ ! -f "$entity" ] || [ ! -d "$entity" ]) && {
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
	ln -nsv "$target" "$link_name" # not yet linked and no exists
done
