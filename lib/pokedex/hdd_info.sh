#!/bin/bash
# 虛擬硬碟資訊


## info.txt
# <name>   <size>   [<start>-<end>/<number>]   [ <start> - <end> / <grainSector> (<grainSize>) ]


__filename=`realpath "$0"`
_dirsh=`dirname "$__filename"`
_binsh=`realpath "$_dirsh/../../bin"`
_libsh=`realpath "$_dirsh/.."`
_fileName=`basename "$0"`


opt_update=0
fnMain() {
    local opt val

    while [ -n 1 ]
    do
        opt="$1"
        val="$2"

        if [ -z "`echo "$opt" | grep "^-"`" ]; then
            for opt in "$@"
            do
                if [ -n "`echo "$opt" | grep "^-"`" ]; then
                    echo "[錯誤] 命令用法： \`<命令> [選項] [參數]\`。"
                    exit 1
                fi
            done

            break
        fi

        case "$opt" in
            "--update" )
                opt_update=1
                shift
                ;;
            * )
                echo "[錯誤] 非法選項 $opt"
                exit 1
                ;;
        esac
    done

    fnMainHandle "$@"
}

fnMainHandle() {
    local vhddDirPath=`"$_libsh/basesh/path.resolve" "$1"`


    if [ ! -f "$vhddDirPath/info.txt" ]; then
        tmpErrMsg="[錯誤] 虛擬硬碟目錄未提供或不正確。"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi


    if [ $opt_update -eq 1 ] || [ ! -f "$vhddDirPath/.pokedex_hddInfo.tmp" ]; then
        "$_dirsh/hdd_info_check.sh" "$vhddDirPath"
        if [ $? -eq 1 ]; then exit 1; fi
    elif [ -n "`cat "$vhddDirPath/info.txt"`" ] && [ -z "`cat "$vhddDirPath/info.txt" | sed -n "1p" | grep "^# overdue"`" ]; then
        cat "$vhddDirPath/info.txt"
        exit
    fi


    local tmp
    local amount totalSize totalGrainSizeM
    local lenName lenSize lenNum lenGrainSector
    local vhddInfo vhddInfoSummary txtVhddInfo txtVhddInfoSummary

    vhddInfo=`cat "$vhddDirPath/.pokedex_hddInfo.tmp"`

    if [ -z "$vhddInfo" ]; then
        cat /dev/null > "$vhddDirPath/info.txt"
        exit
    fi

    vhddInfoSummary=`echo -e "$vhddInfo" | sed -n "1p"`
    vhddInfo=`       echo -e "$vhddInfo" | sed    "1d"`


    amount=`         echo "$vhddInfoSummary" | cut -d " " -f 2`
    totalSize=`      echo "$vhddInfoSummary" | cut -d " " -f 4`
    totalGrainSizeM=`echo "$vhddInfoSummary" | cut -d " " -f 6`
    totalSize=`      "$_dirsh/sizeUnit.sh" $totalSize`
    totalGrainSizeM=`"$_dirsh/sizeUnit.sh" $(( $totalGrainSizeM * 1024 * 1024 ))`
    txtVhddInfoSummary="amount: $amount, totalSize: $totalSize, totalGrainSize: $totalGrainSizeM"


    txtVhddInfo=`echo -e "$vhddInfo" | cut -d " " -f 2,3,4,5,6`
    fnHandleVhddInfo "$txtVhddInfo"
    txtVhddInfo="$rtnHandleVhddInfo"

    lenName=`       echo -e "$txtVhddInfo" | cut -d " " -f 1 | wc -L`
    lenNum=`        echo -e "$txtVhddInfo" | cut -d " " -f 5 | wc -L`
    lenGrainSector=`echo -e "$txtVhddInfo" | cut -d " " -f 8 | wc -L`

    tmp=`        echo -e "$txtVhddInfo" | cut -d " " -f 3`
    tmp="$tmp\n"`echo -e "$txtVhddInfo" | cut -d " " -f 10`
    lenSize=`echo -e "$tmp" | wc -L`

    tmp="%-${lenName}s (%s)  %${lenSize}s   [%${lenNum}s-%${lenNum}s/%${lenNum}s]"
    tmp="$tmp   [ %${lenGrainSector}s - %${lenGrainSector}s / %${lenGrainSector}s (%${lenSize}s) ]\n"
    txtVhddInfo=`printf "$tmp" $txtVhddInfo | sed "1i $txtVhddInfoSummary\n"`


    echo "$txtVhddInfo" > "$vhddDirPath/info.txt"
    cat "$vhddDirPath/info.txt"
}


rtnHandleVhddInfo=""
fnHandleVhddInfo() {
    local txtVhddInfo="$1"

    local numNumber name size grainSizeM numGrainSizeM prevNumGrainSizeM
    local recordName=""
    local recordGrainSizeM=0
    local recordSize=0
    local recordStartNum=0
    local recordEndNum=0
    local recordStartGrainSizeM=0
    local recordEndGrainSizeM=0

    local idx val
    local lenTxtVhddInfo=`echo -e "$txtVhddInfo" | wc -l`

    val=`echo -e "$txtVhddInfo" | sed -n "1p"`
    recordStartNum=`   echo "$val" | cut -d " " -f 1`
    recordName=`       echo "$val" | cut -d " " -f 2`
    recordGrainSizeM=` echo "$val" | cut -d " " -f 4`
    prevNumGrainSizeM=`echo "$val" | cut -d " " -f 5`

    for idx in `seq 1 $lenTxtVhddInfo`
    do
        "$_libsh/basesh/runingDot" $idx

        val=`echo -e "$txtVhddInfo" | sed -n "${idx}p"`
        numNumber=`    echo "$val" | cut -d " " -f 1`
        name=`         echo "$val" | cut -d " " -f 2`
        size=`         echo "$val" | cut -d " " -f 3`
        grainSizeM=`   echo "$val" | cut -d " " -f 4`
        numGrainSizeM=`echo "$val" | cut -d " " -f 5`

        if [ "$name" == "$recordName" ] \
            && [ $numGrainSizeM -eq $prevNumGrainSizeM ] \
            && [ $numNumber -eq $(( $recordEndNum + 1 )) ]
        then
            recordSize=$(( $recordSize + $size ))
            recordEndNum=$numNumber
            recordEndGrainSizeM=$(( $recordEndGrainSizeM + $numGrainSizeM ))
        else
            fnResolveVhddInfo_record \
                $recordName $recordGrainSizeM $recordSize \
                $recordStartNum $recordEndNum \
                $recordStartGrainSizeM $recordEndGrainSizeM

            prevNumGrainSizeM=$numGrainSizeM
            recordName="$name"
            recordGrainSizeM=$grainSizeM
            recordStartNum=$numNumber
            recordStartGrainSizeM=$recordEndGrainSizeM

            recordSize=$size
            recordEndNum=$numNumber
            recordEndGrainSizeM=$(( $recordEndGrainSizeM + $numGrainSizeM ))
        fi
    done

    fnResolveVhddInfo_record \
        $recordName $recordGrainSizeM $recordSize \
        $recordStartNum $recordEndNum \
        $recordStartGrainSizeM $recordEndGrainSizeM


    rtnHandleVhddInfo=`echo -e "$rtnHandleVhddInfo" | sed "1d"`
}
fnResolveVhddInfo_record() {
    local recordName="$1"
    local recordGrainSizeM=$2
    local recordSize=$3
    local recordStartNum=$4
    local recordEndNum=$5
    local recordStartGrainSizeM=$6
    local recordEndGrainSizeM=$7

    local totalGrainSizeM=$(( $recordEndGrainSizeM - $recordStartGrainSizeM ))
    local sizeUnit=`"$_dirsh/sizeUnit.sh" $recordSize`
    local totalGrainSizeUnit=`"$_dirsh/sizeUnit.sh" $(( $totalGrainSizeM * 1024 * 1024 ))`

    rtnHandleVhddInfo="$rtnHandleVhddInfo\n`printf "%s %s %s %s %s %s %s %s %s %s" \
        "$recordName" \
         $recordGrainSizeM \
         $sizeUnit \
         $recordStartNum \
         $recordEndNum \
        $(( $recordEndNum - $recordStartNum + 1 )) \
        $(( $recordStartGrainSizeM * 1024 * 2 )) \
        $(( $recordEndGrainSizeM * 1024 * 2 - 1 )) \
        $(( $totalGrainSizeM * 1024 * 2 )) \
         $totalGrainSizeUnit`"
}


fnMain "$@"

