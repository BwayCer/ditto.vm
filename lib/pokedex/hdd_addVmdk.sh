#!/bin/bash
# 新增虛擬硬碟


# 關於本腳本與所遇問題
# https://github.com/BwayCer/ditto.vm/blob/Rotom/Rotom/pokedex/README.md#問題集-1


##shStyle ###


_originPlace="lib"

_shScript() {
    case "$1" in
    esac
}


##shStyle 介面函式


fnHelp_main() { echo "# 新增虛擬硬碟。
# 磁區名稱： [A-Za-z0-9_]
# 單磁區大小： (0008|0032|0064|0128|0512|4064)
# 起始編號： (1-999)
# 數量： (1-999)
[[USAGE]] <目標目錄>
      < [<磁區名稱>] <單磁區大小> [<起始編號>] <數量>
      | <[<磁區名稱>:]<單磁區大小>:[<起始編號>:]<數量>[ ...]> >
[[OPT]]
      --noconfirm   忽略確認對話。
  -h, --help        幫助。
"; }
fnOpt_main() {
    case "$1" in
        --noconfirm )
            opt_noconfirm=1
            return 1
            ;;
        -h | --help ) fnShowHelp ;;
        * ) return 3 ;;
    esac
}
fnMain() {
    opt_noconfirm=0
    fnParseOption

    local vhddDirPath=`"$_libsh/basesh/path.resolve" "${_args[0]}"`
    local otherParameter=("${_args[@]:1}")

    local val
    local regexParseOptionA="^\(\([A-Za-z][A-Za-z0-9_]*\) \+\)\?"
    regexParseOptionA+="\(0008\|0032\|0064\|0128\|0512\|4064\) \+"
    regexParseOptionA+="\(\([1-9][0-9]\{,2\}\) \+\)\?"
    regexParseOptionA+="\([1-9][0-9]\{,2\}\) *$"
    local regexParseOptionB="^\(\([A-Za-z][A-Za-z0-9_]*\):\)\?"
    regexParseOptionB+="\(0008\|0032\|0064\|0128\|0512\|4064\):"
    regexParseOptionB+="\(\([1-9][0-9]\{,2\}\):\)\?"
    regexParseOptionB+="\([1-9][0-9]\{,2\}\)$"

    if   [ -n "`echo "${otherParameter[@]}" | grep "$regexParseOptionA"`" ]; then
        printf "";
    elif [ -n "`echo "${otherParameter[0]}" | grep "$regexParseOptionB"`" ]; then
        for val in "${otherParameter[@]}"
        do
            if [ -z "`echo "$val" | grep "$regexParseOptionB"`" ]; then
                Loxog err "[錯誤] 請再次檢查參數。"
                exit 1
            fi
        done
    else
        Loxog err "[錯誤] 請再次檢查參數。"
        exit 1
    fi

    if [ ! -f "$vhddDirPath/info.txt" ]; then
        mkdir -p "$vhddDirPath" "$vhddDirPath/vHDD/"
        if [ $? -eq 1 ]; then
            Loxog err "[錯誤] 無法在指定路徑建立目標目錄。"
            exit 1
        fi

        cat /dev/null > "$vhddDirPath/info.txt"
        touch "$vhddDirPath/interface.vmdk"
    elif [ ! -d "$vhddDirPath/vHDD/" ]; then
        mkdir "$vhddDirPath/vHDD/"
    fi

    "$_dirsh/hdd_info_check.sh" "$vhddDirPath"
    if [ $? -eq 1 ]; then exit 1; fi


    if [ -n "`echo "${otherParameter[@]}" | grep "$regexParseOptionA"`" ]; then
        addVmdk $opt_noconfirm "$vhddDirPath" \
            "`echo "$@" | sed "s/$regexParseOptionA/\2/"`" \
            "`echo "$@" | sed "s/$regexParseOptionA/\3/"`" \
            "`echo "$@" | sed "s/$regexParseOptionA/\5/"`" \
            "`echo "$@" | sed "s/$regexParseOptionA/\6/"`"
        if [ $? -eq 1 ]; then exit 1; fi
    elif [ -n "`echo "${otherParameter[0]}" | grep "$regexParseOptionB"`" ]; then
        for val in "${otherParameter[@]}"
        do
            addVmdk $opt_noconfirm "$vhddDirPath" \
                "`echo "$val" | sed "s/$regexParseOptionB/\2/"`" \
                "`echo "$val" | sed "s/$regexParseOptionB/\3/"`" \
                "`echo "$val" | sed "s/$regexParseOptionB/\5/"`" \
                "`echo "$val" | sed "s/$regexParseOptionB/\6/"`"
            if [ $? -eq 1 ]; then exit 1; fi
        done
    fi


    echo -e "\n\ninfo.txt"
    "$_dirsh/pokedex.sh" hdd info "$vhddDirPath"
}


##shStyle 共享變數



##shStyle 函式庫


addVmdk() {
    local tmp
    local bisNoConfirm=$1
    local vhddDirPath="$2"
    local name="$3"
    local grainSizeM="$4"
    local startNum=$5
    local totalNum=$6

    if [ ! -f "$vhddDirPath/info.txt" ] || [ ! -d "$vhddDirPath/vHDD/" ]; then
        tmpErrMsg="[錯誤] 虛擬硬碟目錄未提供或不正確。"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi

    if [ ! -f "$vhddDirPath/.pokedex_hddInfo.tmp" ]; then
        tmpErrMsg="[錯誤] 缺少文件。 (\".pokedex_hddInfo.tmp\")"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi


    local amount totalSize totalGrainSizeM
    local vhddInfo vhddInfoSummary txtVhddInfo
    local bisHasOriginVhddInfo=0
    local endNum


    vhddInfo=`cat "$vhddDirPath/.pokedex_hddInfo.tmp"`
    vhddInfoSummary=`echo -e "$vhddInfo" | sed -n "1p"`
    vhddInfo=`       echo -e "$vhddInfo" | sed    "1d"`
    txtVhddInfo="$vhddInfo"

    amount=`         echo "$vhddInfoSummary" | cut -d " " -f 2`
    totalSize=`      echo "$vhddInfoSummary" | cut -d " " -f 4`
    totalGrainSizeM=`echo "$vhddInfoSummary" | cut -d " " -f 6`
    bisHasOriginVhddInfo=$totalGrainSizeM

    tmp="amount: \(0\|[1-9][0-9]*\)"
    tmp+=" totalSize: \(0\|[1-9][0-9]*\) totalGrainSizeM: \(0\|[1-9][0-9]*\)"
    if [ -z "`echo "$vhddInfoSummary" | grep "^$tmp$"`" ]; then
        tmpErrMsg="[錯誤] \".pokedex_hddInfo.tmp\" 文件的概括資訊與期望不符。"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi


    if [ -z "$startNum" ]; then
        if [ $bisHasOriginVhddInfo -eq 0 ]; then
            startNum=1
        else
            tmp=`echo -e "$vhddInfo" | cut -d " " -f 2 | sort -rn`
            startNum=`echo -e "$tmp" | sed -n "1p"`
            if [ $startNum -eq 999 ]; then
                startNum=`echo -e "$tmp" | sed -n "2p"`
            fi
            startNum=$(( $startNum + 1 ))
        fi
    fi

    endNum=$(( $startNum + $totalNum - 1 ))

    if [ $endNum -gt 999 ]; then
        tmpErrMsg="[錯誤] 虛擬硬碟編號數超過 999。"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi


    if [ $bisNoConfirm -eq 0 ] && [ $bisHasOriginVhddInfo -ne 0 ]; then
        fnCheckExistFile "$vhddDirPath" $startNum $endNum "$txtVhddInfo"
        amount=$(( $amount - $fnCheckExistFile_subtractionAmount ))
        totalSize=$(( $totalSize - $fnCheckExistFile_subtractionTotalSize ))
        totalGrainSizeM=$((
            $totalGrainSizeM - $fnCheckExistFile_subtractionTotalGrainSizeM
        ))
        txtVhddInfo="$fnCheckExistFile_vhddInfo"
    fi


    fnHandleCreateVhdd \
        "$vhddDirPath" "$name" "$grainSizeM" $startNum $endNum \
        "`echo -e "$txtVhddInfo" | cut -d " " -f 1`"

    if [ $rtnHandleCreateVhdd_addTotalGrainSizeM -gt 0 ]; then
        amount=$(( $amount + $rtnHandleCreateVhdd_addAmount ))
        totalSize=$(( $totalSize + $rtnHandleCreateVhdd_addTotalSize ))
        totalGrainSizeM=$(( $totalGrainSizeM + $rtnHandleCreateVhdd_addTotalGrainSizeM ))

        if [ $bisHasOriginVhddInfo -eq 0 ]; then
            txtVhddInfo="$rtnHandleCreateVhdd_addVhddInfo"
        else
            txtVhddInfo="$txtVhddInfo\n$rtnHandleCreateVhdd_addVhddInfo"
        fi

        txtVhddInfo=`echo -e "$txtVhddInfo" | sort -n`
    fi


    tmp="amount: $amount totalSize: $totalSize totalGrainSizeM: $totalGrainSizeM"
    echo -e "$txtVhddInfo" | sed "1i $tmp" > "$vhddDirPath/.pokedex_hddInfo.tmp"
    fnRemindUpdateInfo "$vhddDirPath"
    fnGetVmdkInterface $totalGrainSizeM "`echo -e "$txtVhddInfo" | cut -d " " -f 9-`"
    echo -e "$rtnGetVmdkInterface" > "$vhddDirPath/interface.vmdk"
}

fnRemindUpdateInfo() {
    local vhddDirPath="$1"
    local UpdateRemindInfo="# overdue"

    if [ -z "`cat "$vhddDirPath/info.txt" | sed -n "1p" | grep "$UpdateRemindInfo"`" ]; then
        sed -i "1i $UpdateRemindInfo" "$vhddDirPath/info.txt"
    fi
}

fnCheckExistFile_subtractionAmount=0
fnCheckExistFile_subtractionTotalSize=0
fnCheckExistFile_subtractionTotalGrainSizeM=0
fnCheckExistFile_vhddInfo=""
fnCheckExistFile() {
    local vhddDirPath="$1"
    local startNum=$2
    local endNum=$3
    local vhddInfo="$4"

    local val
    local lineNumber size numGrainSizeM fileName
    local warnList=()
    local vhddNumberList=`echo -e "$vhddInfo" | cut -d " " -f 1`
    local amount=0
    local totalSize=0
    local totalGrainSizeM=0

    for val in `seq $startNum $endNum`
    do
        val=`printf "%03d" $val`

        if [ -z "`echo $vhddNumberList | grep "$val"`" ]; then continue; fi
        warnList[ ${#warnList[@]} ]=$val
    done

    if [ ${#warnList[@]} -ne 0 ]; then
        echo "以下文件已存在： ${warnList[@]}"
        "$_libsh/basesh/prompt" "是否選擇覆蓋已存在文件" "Yes|Y|yes|y" "No|N|no|n:*"
        if [ "`"$_libsh/basesh/prompt" rtnAnswer`" == "Yes" ]; then
            for val in ${warnList[@]}
            do
                lineNumber=`   echo -e "$vhddInfo" | grep -n "^$val" | cut -d ":" -f 1`
                size=`         echo -e "$vhddInfo" | grep    "^$val" | cut -d " " -f 4`
                numGrainSizeM=`echo -e "$vhddInfo" | grep    "^$val" | cut -d " " -f 6`
                fileName=`     echo -e "$vhddInfo" | grep    "^$val" | cut -d " " -f 8`

                amount=$(( $amount + 1 ))
                totalSize=$(( $totalSize + $size ))
                totalGrainSizeM=$(( $totalGrainSizeM + $numGrainSizeM ))
                vhddInfo=`echo -e "$vhddInfo" | sed "${lineNumber}d"`
                rm "$vhddDirPath/vHDD/$fileName"
            done
        fi
    fi

    fnCheckExistFile_subtractionAmount=$amount
    fnCheckExistFile_subtractionTotalSize=$totalSize
    fnCheckExistFile_subtractionTotalGrainSizeM=$totalGrainSizeM
    fnCheckExistFile_vhddInfo="$vhddInfo"
}

fnobjVmdkSample_sourceFile=""
fnobjVmdkSample_size=""
fnobjVmdkSample_numGrainSizeM=""
fnobjSampleVhddInfo() {
    local chooseSize="$1"

    local sourceFile size numGrainSizeM

    case $chooseSize in
        "0008" )
            sourceFile="sampleGrain_0008M_s16384.vmdk"
            size=65536
            numGrainSizeM=8
            ;;
        "0032" )
            sourceFile="sampleGrain_0032M_s65536.vmdk"
            size=65536
            numGrainSizeM=32
            ;;
        "0064" )
            sourceFile="sampleGrain_0064M_s131072.vmdk"
            size=131072
            numGrainSizeM=64
            ;;
        "0128" )
            sourceFile="sampleGrain_0128M_s262144.vmdk"
            size=65536
            numGrainSizeM=128
            ;;
        "0512" )
            sourceFile="sampleGrain_0512M_s1048576.vmdk"
            size=131072
            numGrainSizeM=512
            ;;
        "4064" )
            sourceFile="sampleGrain_4064M_s8323072.vmdk"
            size=524288
            numGrainSizeM=4064
            ;;
    esac

    fnobjVmdkSample_sourceFile="$sourceFile"
    fnobjVmdkSample_size="$size"
    fnobjVmdkSample_numGrainSizeM="$numGrainSizeM"
}

fnCopyVmdk() {
    local source="$1"
    local targetName="$2"

    cp "$source" "$targetName"
    if [ ! -e "$targetName" ]; then fnCopyVmdk "$source" "$targetName"; fi
}

rtnHandleCreateVhdd_addAmount=0
rtnHandleCreateVhdd_addTotalSize=0
rtnHandleCreateVhdd_addTotalGrainSizeM=0
rtnHandleCreateVhdd_addVhddInfo=""
fnHandleCreateVhdd() {
    local vhddDirPath="$1"
    local name="$2"
    local grainSizeM="$3"
    local startNum=$4
    local endNum=$5
    local existVhddNumber="$6"


    local tmp
    local loopA idx
    local joinName grainSource
    local number numNumber size numGrainSizeM grainSector fileName interfaceInfo
    local vhddDirName=`basename "$vhddDirPath"`
    local amount=0
    local totalSize=0
    local totalGrainSizeM=0
    local addVhddInfo=""


    if [ -n "$name" ]; then
        joinName="-$name"
    else
        name="---"
    fi

    fnobjSampleVhddInfo "$grainSizeM"
    grainSource="$fnobjVmdkSample_sourceFile"
    size="$fnobjVmdkSample_size"
    numGrainSizeM="$fnobjVmdkSample_numGrainSizeM"
    grainSector=$(( $numGrainSizeM * 1024 * 2 ))


    loopA=0

    for idx in `seq $startNum $endNum`
    do
        loopA=$(( $loopA + 1 ))
        number=`printf "%03d" $idx`
        numNumber=$idx
        fileName="s$number-g$grainSizeM"$joinName".vmdk"
        interfaceInfo=`printf 'RW %7s SPARSE "%s"' "$grainSector" "../$vhddDirName/vHDD/$fileName"`

        printf "\r%-18s  [%3s/%3s]   %3s" "$name" "$loopA" "$totalNum" "$number"

        if [ -n "`echo "$existVhddNumber" | grep "$number"`" ]; then continue; fi

        fnCopyVmdk "$_dirsh/hdd/$grainSource" "$vhddDirPath/vHDD/$fileName"

        amount=$(( $amount + 1 ))
        totalSize=$(( $totalSize + $size ))
        totalGrainSizeM=$(( $totalGrainSizeM + $numGrainSizeM ))

        tmp="$number $numNumber $name $size $grainSizeM $numGrainSizeM $grainSector $fileName $interfaceInfo"
        addVhddInfo="$addVhddInfo\n""$tmp"
    done

    printf "\r%-18s  [%3s-%3s/%3s]   OK\n" \
        "$name" \
        "`printf "%03d" $startNum`" \
        "`printf "%03d" $endNum`" \
        "$loopA"


    rtnHandleCreateVhdd_addAmount=$amount
    rtnHandleCreateVhdd_addTotalSize=$totalSize
    rtnHandleCreateVhdd_addTotalGrainSizeM=$totalGrainSizeM
    rtnHandleCreateVhdd_addVhddInfo=`echo -e "$addVhddInfo" | sed "1d"`
}

rtnGetVmdkInterface=""
fnGetVmdkInterface() {
rtnGetVmdkInterface='# Disk DescriptorFile
version=1
encoding="Big5"
CID=ffffffff
parentCID=ffffffff
isNativeSnapshot="no"
createType="twoGbMaxExtentSparse"

# Extent description
'$2'

# The Disk Data Base
#DDB

ddb.adapterType = "lsilogic"
ddb.geometry.cylinders = "'$1'"
ddb.geometry.heads = "64"
ddb.geometry.sectors = "32"
ddb.longContentID = "ffffffffffffffffffffffffffffffff"
ddb.uuid = "ff ff ff ff ff ff ff ff-ff ff ff ff ff ff ff ff"
ddb.virtualHWVersion = "12"'
}


##shStyle 腳本環境


__filename=`realpath "$0"`
_dirsh=`dirname "$__filename"`
[ "$_originPlace" == "bin" ] && _binsh=$_dirsh || _binsh=`realpath "$_dirsh/../../bin"`
[ "$_originPlace" == "bin" ] && _libsh=`realpath "$_dirsh/../lib"` || _libsh=`realpath "$_dirsh/.."`
_fileName=`basename "$0"`

_PWD=$PWD
_br="
"

# 0 黑 black
# 1 紅 red
# 2 綠 green
# 3 黃 yellow
# 4 藍 blue
# 5 粉 magenta
# 6 青 cyan
# 7 白 white
_fColor() {
    local color=$1
    local bold=$2
    local bgcolor=$3
    local underline=$4

    [ $_fColor_usable -eq 0 ] && [ $_fColor_force -eq 0 ] && return

    if [ "$color" == "N" ]; then
        [ $_fColor_force -eq 0 ] \
            && printf "`tput sgr0`" \
            || printf "\e[00m"

        return
    fi

    case "$color" in
        [01234567] )
            [ $_fColor_force -eq 0 ] \
                && printf "`tput setaf $color`" \
                || printf "\e[3${color}m"
            ;;
    esac

    case "$bgcolor" in
        [01234567] )
            [ $_fColor_force -eq 0 ] \
                && printf "`tput setab $bgcolor`" \
                || printf "\e[4${bgcolor}m"
            ;;
    esac

    if [ "$bold" == "1" ]; then
        [ $_fColor_force -eq 0 ] \
            && printf "`tput bold`" \
            || printf "\e[01m"
    fi

    if [ "$underline" == "1" ]; then
        [ $_fColor_force -eq 0 ] \
            && printf "`tput smul`" \
            || printf "\e[04m"
    fi
}
_fColor_usable=0
_fColor_force=0

_fN=""
_fRedB=""
_fYelB=""

Loxog() {
    local _stdin=`[ ! -t 0 ] && { \
        IFS='';
        while read pipeData; do echo "$pipeData"; done <&0;
        unset IFS
    }`
    local method="$1"; shift

    local color formatArgus

    case $method in
        com ) color=$_fN    ;; # common
        war ) color=$_fYelB ;; # warn
        err ) color=$_fRedB ;; # error
    esac

    formatArgus="$color%s$_fN\n"

    local idx val len

    [ -n "$*" ] && printf "$formatArgus" "$@" 1>&2

    [ -z "$_stdin" ] && return
    len=`echo "$_stdin" | wc -l`
    for idx in `seq 1 $len`
    do
        val=`echo "$_stdin" | sed -n "${idx}p"`
        printf "$formatArgus" "$val" 1>&2
    done
}

_onCtrlC() {
    local val
    for val in "$@"
    do
        _onCtrlC_cmd+=$val$_br
    done
    trap 'sh -c "echo ; $_onCtrlC_cmd echo"; exit' 2
}
_onCtrlC_cmd=""


##shStyle ###


[ -L "$0" ] && exec "`realpath "$0"`" "$@"

_stdin=`[ ! -t 0 ] && while read pipeData; do echo $pipeData; done <&0`

_args=("$@")
_origArgs=("$@")

argsShift() {
    local amount=$1

    if [ -z "$amount" ] || [ $amount -lt 1 ]; then amount=1; fi
    _args=("${_args[@]:$amount}")
}

tmp=`tput colors`
[ -t 1 ] && [ -n "$tmp" ] && [ $tmp -ge 8 ] && _fColor_usable=1
_fnForceColor() {
    [ "$1" == 1 ] && _fColor_force=1
    _fN=`_fColor N`
    _fRedB=`_fColor 1 1`
    _fYelB=`_fColor 3 1`
}
_fnForceColor

fnParseOption() {
    local fnHandleOpt="fnOpt_$_shCmd"

    local tmp args opt val cutLen errMsg
    args=("${_args[@]}")
    errMsg=""

    while [ 1 ]
    do
        opt=${args[0]}
        val=${args[1]}
        cutLen=2

        if [ "$opt" == "--" ] || [ -z "`echo "_$opt" | grep "^_-"`" ]; then break; fi

        if [ -n "`echo "_$opt" | grep "^_-[^-]"`" ] && [ ${#opt} -ne 2 ]; then
            tmp="-"${opt:2}
            opt=${opt:0:2}
            val=""
            cutLen=1
            args=("$opt" "$tmp" "${args[@]:1}")
        elif [ -n "`echo "_$val" | grep "^_-"`" ]; then
            val=""
            cutLen=1
        fi

        if [ "$opt" == "--color" ]; then
            _fnForceColor 1
            tmp=1
        else
            $fnHandleOpt "$opt" "$val"
            tmp=$?
        fi
        case $tmp in
            0 )
                echo '請檢查 "'$fnHandleOpt'" 的錯誤回傳值。' 1>&2
                exit
                ;;
            # 使用 1 個參數
            1 )
                [ $cutLen -eq 2 ] && (( cutLen-- ))
                ;;
            # 使用 2 個參數
            2 ) ;;
            3 )
                errMsg+=$_br'找不到 "'$opt'" 選項。'
                ;;
            4 )
                [ "$val" == "" ] && val="null" || val='"'$val'"'
                errMsg+=$_br$val' 不符合 "'$opt'" 選項的預期值。'
                ;;
        esac

        args=("${args[@]:$cutLen}")
    done

    if [ "${args[0]}" == "--" ]; then
        args=("${args[@]:1}")
    else
        for val in "${args[@]}"
        do
            [ -z "`echo "_$val" | grep "^_-"`" ] && continue

            errMsg+=$_br'不符合 "[命令] [選項] [參數]" 的命令用法。'
            break
        done
    fi

    if [ -z "$errMsg" ]; then
        _args=("${args[@]}")
        return
    fi

    echo "$errMsg" | sed "1d" \
        | sed "s/^\(.\)/[$_fileName]: \1/" \
        | Loxog err
    exit 1
}

fnShowHelp() {
    local txtHelp=`fnHelp_$_shCmd`

    local bisUsage bisSubCmd bisOpt
    local usage
    bisUsage=` echo "$txtHelp" | grep "\[\[USAGE\]\]"`
    bisSubCmd=`echo "$txtHelp" | grep "\[\[SUBCMD\]\]"`
    bisOpt=`   echo "$txtHelp" | grep "\[\[OPT\]\]"`

    if [ -n "$bisUsage" ]; then
        usage="用法："
        [ -n "$bisSubCmd" ] && usage+=" [命令]"
        [ -n "$bisOpt" ] && usage+=" [選項]"

        txtHelp=`echo "$txtHelp" | sed "s/\[\[USAGE\]\]/\n$usage/"`
    fi

    [ -n "$bisSubCmd" ] && \
        txtHelp=`echo "$txtHelp" | sed "s/\[\[SUBCMD\]\]/\\n\\n命令：\\n/"`

    [ -n "$bisOpt" ] && \
        txtHelp=`echo "$txtHelp" | sed "s/\[\[OPT\]\]/\\n\\n選項：\\n/"`

    echo "$txtHelp$_br"
    exit
}


_shCmd=""
_shCmdLevel=0
_shScript "$@"
if [ $_shCmdLevel -eq 0 ]; then
    _shCmd="main"
    fnMain "$@"
    exit
fi
for tmp in `seq 0 $(( $_shCmdLevel -1 ))`
do _shCmd+="_${_args[ $tmp ]}"; done
argsShift $_shCmdLevel
_shCmd=${_shCmd:1}
fnMain_$_shCmd "${_args[@]}"

