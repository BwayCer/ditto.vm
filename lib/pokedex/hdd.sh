#!/bin/bash
# 虛擬硬碟


__filename=`realpath "$0"`
_dirsh=`dirname "$__filename"`
_binsh=`realpath "$_dirsh/../../bin"`
_libsh=`realpath "$_dirsh/.."`
_fileName=`basename "$0"`


fnMain() {
    cmd="$1"; shift

    case "$cmd" in
        "info" )
            "$_dirsh/hdd_info.sh" "$@"
            ;;
        "add" )
            fnHddAdd "$@"
            ;;
    esac
}


fnHddAdd() {
    local simpleCheck

    simpleCheck=`"$_dirsh/hdd_addVmdk.sh" --simpleCheck "$@"`
    if [ $? -eq 1 ]; then
        echo "$simpleCheck"
        exit 1;
    fi

    local tmp txtOptArgu
    local lenVhddArgu=`echo "$simpleCheck" | cut -d " " -f 1`
    local vhddDirPath=`echo "$simpleCheck" | cut -d " " -f 2-`

    tmp=`echo "$vhddDirPath" | sed 's/\(\^\|\\\$\|\[\|\]\|\.\|\*\|\/\|\\\\\)/\\\\\\1/g'`
    txtOptArgu=`echo "$@" | sed "s/\(\(.*\) \)\?$tmp.*/\1/"`

    shift $(( $# - $lenVhddArgu ))


    local val
    local regexParseOptionA="^\(\([A-Za-z][A-Za-z0-9_]*\) \+\)\?\(0008\|0128\|0512\|4064\) \+"
    regexParseOptionA=$regexParseOptionA"\(\([1-9][0-9]\{,2\}\) \+\)\?\([1-9][0-9]\{,2\}\) *$"
    local regexParseOptionB="^\(\([A-Za-z][A-Za-z0-9_]*\):\)\?\(0008\|0128\|0512\|4064\):"
    regexParseOptionB=$regexParseOptionB"\(\([1-9][0-9]\{,2\}\):\)\?\([1-9][0-9]\{,2\}\)$"


    if   [ -n "`echo "$@" | grep "$regexParseOptionA"`" ]; then printf "";
    elif [ -n "`echo "$1" | grep "$regexParseOptionB"`" ]; then
        for val in "$@"
        do
            if [ -z "`echo "$val" | grep "$regexParseOptionB"`" ]; then
                tmpErrMsg="[錯誤] 請再次檢查參數。"
                echo -e "\e[01;31m${tmpErrMsg}\e[00m"
                exit 1
            fi
        done
    else
        tmpErrMsg="[錯誤] 請再次檢查參數。"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi


    if [ ! -f "$vhddDirPath/info.txt" ]; then
        mkdir -p "$vhddDirPath" "$vhddDirPath/vHDD/"
        cat /dev/null > "$vhddDirPath/info.txt"
        touch "$vhddDirPath/interface.vmdk"
    elif [ ! -d "$vhddDirPath/vHDD/" ]; then
        mkdir "$vhddDirPath/vHDD/"
    fi

    "$_dirsh/hdd_info_check.sh" "$vhddDirPath"
    if [ $? -eq 1 ]; then exit 1; fi


    if [ -n "`echo "$@" | grep "$regexParseOptionA"`" ]; then
        "$_dirsh/hdd_addVmdk.sh" $txtOptArgu $optNoConfirm "$vhddDirPath" \
            "`echo "$@" | sed "s/$regexParseOptionA/\2/"`" \
            "`echo "$@" | sed "s/$regexParseOptionA/\3/"`" \
            "`echo "$@" | sed "s/$regexParseOptionA/\5/"`" \
            "`echo "$@" | sed "s/$regexParseOptionA/\6/"`"
        if [ $? -eq 1 ]; then exit 1; fi
    elif [ -n "`echo "$1" | grep "$regexParseOptionB"`" ]; then
        for val in "$@"
        do
            "$_dirsh/hdd_addVmdk.sh" $txtOptArgu $optNoConfirm "$vhddDirPath" \
                "`echo "$val" | sed "s/$regexParseOptionB/\2/"`" \
                "`echo "$val" | sed "s/$regexParseOptionB/\3/"`" \
                "`echo "$val" | sed "s/$regexParseOptionB/\5/"`" \
                "`echo "$val" | sed "s/$regexParseOptionB/\6/"`"
            if [ $? -eq 1 ]; then exit 1; fi
        done
    fi


    echo -e "\n\ninfo.txt"
    "$0" info "$vhddDirPath"
}


fnMain "$@"

