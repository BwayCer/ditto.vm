#!/bin/bash
# 新增虛擬硬碟


# ./host_new.sh
#     <虛擬機名稱>
#     <主機殼路徑>
#     <<小型電腦系統介面埠口號>:<硬碟路徑> ...>


__filename=`realpath "$0"`
_dirsh=`dirname "$__filename"`
_binsh=`realpath "$_dirsh/../../bin"`
_libsh=`realpath "$_dirsh/.."`
_fileName=`basename "$0"`


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
            "--simpleCheck" )
                opt_simpleCheck=1
                shift
                ;;
            "--noconfirm" )
                opt_noConfirm=1
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
    local name="$2"
    local grainSizeM="$3"
    local startNum=$4
    local totalNum=$5

    if [ $opt_simpleCheck -eq 1 ]; then
        shift
        echo $# "$vhddDirPath"
        exit
    fi


    local regexParseOption
    regexParseOption="^\([A-Za-z][A-Za-z0-9_]*\)\? \(0008\|0128\|0512\|4064\) "
    regexParseOption=$regexParseOption"\([1-9][0-9]\{,2\}\)\? \([1-9][0-9]\{,2\}\)$"

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

    if [ -z "`echo "$name $grainSizeM $startNum $totalNum" | grep "$regexParseOption"`" ]; then
        tmpErrMsg="[錯誤] 請再次檢查參數。"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    fi


    local tmp
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

    tmp="amount: \(0\|[1-9][0-9]*\) totalSize: \(0\|[1-9][0-9]*\) totalGrainSizeM: \(0\|[1-9][0-9]*\)"
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


    if [ $opt_noConfirm -eq 0 ] && [ $bisHasOriginVhddInfo -ne 0 ]; then
        fnCheckExistFile "$vhddDirPath" $startNum $endNum "$txtVhddInfo"
        amount=$(( $amount - $fnCheckExistFile_subtractionAmount ))
        totalSize=$(( $totalSize - $fnCheckExistFile_subtractionTotalSize ))
        totalGrainSizeM=$(( $totalGrainSizeM - $fnCheckExistFile_subtractionTotalGrainSizeM ))
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


fnMain "$@"

