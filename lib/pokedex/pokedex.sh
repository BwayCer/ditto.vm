#!/bin/bash
# 圖鑑


if [ -L "$0" ]; then
    originFileName=`realpath "$0"`
    if [ ! -x "$originFileName" ]; then exit 1; fi
    exec "$originFileName" "$@"
fi

