#!/bin/sh
#
# Copyright 2008, 2013-2014, 2017 Jonas Smedegaard <dr@jones.dk>
# Description: Resolves supported archs of a Debian package
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Depends: libwww-perl

set -e

pkgsuite="$(dpkg-parsechangelog -S Distribution)"
case "$pkgsuite" in
	experimental) suite=unstable,experimental;;
	UNRELEASED|'') suite=unstable;;
	*-*) suite="$(echo "$suite" | sed -e 's/-.*//')";;
	*) suite="$pkgsuite";;
esac
[ "$pkgsuite" = "$suite" ] || echo >&2 "WARNING: using suite \"$suite\"."

echo >&2 "INFO: Query Debian for package \"$1\" architectures..."
GET "https://qa.debian.org/madison.php?package=$1&table=debian&s=$suite&text=on" \
	| perl -MList::Util=uniq -F'\|\s*' \
	-E 'for (split(/[,\s]+/, pop @F)) {' \
		-E 'next if ($_ eq "source");' \
		-E '$_ = "any" if ($_ eq "all");' \
		-E 'push @a, $_};' \
	-E 'END{if (@a) {say join(" ", uniq sort @a)} else {say "none"}}'
