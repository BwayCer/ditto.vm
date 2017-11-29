#!/bin/bash
# 大小單位


sizeBytes=$1


size=0
unit=""


if [ $sizeBytes -lt 1024 ]; then
    size=$sizeBytes
    unit="B"
elif [ $sizeBytes -lt 1048576 ]; then
    size=$(( $sizeBytes *  10 /    1024 ))
    size=`echo "$size" | sed "s/\([0-9]\)$/.\1/"`
    unit="K"
elif [ $sizeBytes -lt 1073741824 ]; then
    size=$(( $sizeBytes *  10 / 1048576 ))
    size=`echo "$size" | sed "s/\([0-9]\)$/.\1/"`
    unit="M"
else
    size=$(( $sizeBytes * 100 / 1073741824 ))
    size=`echo "$size" | sed "s/\([0-9]\{2\}\)$/.\1/"`
    unit="G"
fi

echo "${size}${unit}"

