#!/usr/bin/env bash

# Copyright © 2020 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

set -e -u
echo 1..2
base="${0%/*}/.."
base=$(cd -P -- "$base" && pwd)
prog="$base/opensubtitles-dl"
if [ -z "${OPENSUBTITLES_DL_ONLINE_TESTS-}" ]
then
    echo 'OPENSUBTITLES_DL_ONLINE_TESTS is not set' >&2
    printf 'not ok %d\n' 1 2
    exit 1
fi
tmpdir=$(mktemp -t -d opensubtitles-dl.XXXXXX)
cd "$tmpdir"
t_diff()
{
    n=$1
    out=$2
    exp=$3
    diff=$(diff -u <(printf '%s' "$exp") <(printf '%s' "$out")) || true
    if [ -z "$diff" ]
    then
        echo "ok $n"
    else
        sed -e 's/^/# /' <<< "$diff"
        echo "not ok $n"
    fi
}
help=$("$prog" --help)$'\n'
t_diff 1 "$help" $'Usage: opensubtitles-dl FILE URL\n'
touch night-of-the-living-dead.mp4
"$prog" night-of-the-living-dead.mp4 https://www.opensubtitles.org/en/subtitles/4025513/night-of-the-living-dead-en
out=$(grep -B1 "They're coming to" night-of-the-living-dead.srt)$'\n'
t_diff 2 "$out" $'00:06:10,852 --> 00:06:14,117\r\nThey\'re coming to get you, Barbra.\r\n'
cd /
rm -rf "$tmpdir"

# vim:ts=4 sts=4 sw=4 et ft=sh
