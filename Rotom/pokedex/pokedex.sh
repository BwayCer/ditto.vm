#!/bin/bash
# 圖鑑


if [ -L "$0" ]; then
    originFileName=`ls -l "$0" | sed "s/.* -> \(.\+\)/\1/"`

    if [ -z "`echo "$originFileName" | grep "^/"`" ]; then
        originFileName="`dirname "$0"`/$originFileName"
    fi

    if [ ! -x "$originFileName" ]; then exit 1; fi

    "$originFileName" "$@"
    exit $?
fi

