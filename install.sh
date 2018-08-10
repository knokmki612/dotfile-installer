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

append() {
	cat <<- +
		$1
		$2
	+
}

DOTFILES=$(cd "$(dirname "$0")" && pwd)
cd "$DOTFILES" || exit

gitmodules=$(grep 'path' .gitmodules | cut -d ' ' -f 3-)
ignores="$gitmodules"
ignores=$(append "$ignores" ".git")
ignores=$(append "$ignores" "$(basename "$0")")
ignores=$(append "$ignores" "LICENSE")
ignores=$(append "$ignores" "README")

ignore_patterns=$(
	echo "$ignores" |
	awk '{
		gsub(/[. \/]/, "\\\\&")
		print "!/^\\.\\/" $0 "/"
	}'              |
	awk -v final="$(echo "$ignores" | wc -l)" '{
		if (NR!=final) sub(/$/, " \\&\\& \\")
		print $0
	}'
)

targets=$(
	find . -type f |
	awk "$ignore_patterns { print \$0 }"
)
link_dirs=$(
	echo "$targets"      |
	awk -v home="$HOME" '{
		sub(/^\.\//, home "/.")
		print $0
	}'                   |
	tr '\n' '\0'         |
	xargs -0 -n1 dirname |
	grep -v "$HOME$"     |
	uniq
)

echo "$link_dirs" |
tr '\n' '\0'      |
xargs -0 mkdir -p

IFS='
'

for target in $(echo "$targets")
do
	ln -fsv "$DOTFILES/${target#./}" "$HOME/.${target#./}"
done
