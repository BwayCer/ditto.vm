#!/bin/bash
# pacman 程式包快取


__dirname=`dirname "$0"`
binDirPath=$__dirname

logfilePath=$PWD/`basename "$0"`.log


opt_xpvf=0
opt_cpvf=0
fnMain() {
    local tmp opt val

    while [ -n 1 ]
    do
        opt="$1"
        val="$2"

        if [ -z "`echo "$opt" | grep "^-"`" ]; then
            for opt in "$@"
            do
                if [ -n "`echo "$opt" | grep "^-"`" ]; then
                    tmpErrMsg="[錯誤] 命令用法： \`<命令> [選項] [參數]\`。"
                    echo -e "\e[01;31m${tmpErrMsg}\e[00m"
                    exit 1
                fi
            done

            break
        fi

        case "$opt" in
            "--cpvf" )
                opt_pvf=1
                shift
                ;;
            "--xpvf" )
                opt_xpvf=1
                shift
                ;;
            * )
                tmpErrMsg="[錯誤] 非法選項 $opt"
                echo -e "\e[01;31m${tmpErrMsg}\e[00m"
                exit 1
                ;;
        esac
    done

    fnMainHandle "$@"
}

fnMainHandle() {
    local tmp

    if [ $opt_xpvf -eq $opt_cpvf ]; then
        tmpErrMsg="[錯誤] 非法選項 $opt"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi

opt_cpvf=0
    tmp=`ls /home/cachePacmanPkg-v4.*.tar`
    if [ -n "$tmp" ]; then
        tmp=`echo "$tmp" | sort -rn | sed -n "1p"`
        fnRecordHistory tar -xvf "$tmp" -C /mnt/
    fi
}


fnMain "$@"

