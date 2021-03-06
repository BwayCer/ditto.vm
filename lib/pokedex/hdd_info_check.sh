#!/bin/bash
# 虛擬硬碟資訊 - 檢查


__filename=`realpath "$0"`
_dirsh=`dirname "$__filename"`
_binsh=`realpath "$_dirsh/../../bin"`
_libsh=`realpath "$_dirsh/.."`
_fileName=`basename "$0"`


fnMain() {
    local vhddDirPath=`"$_libsh/basesh/path.resolve" "$1"`


    if [ ! -f "$vhddDirPath/info.txt" ]; then
        tmpErrMsg="[錯誤] 虛擬硬碟目錄未提供或不正確。"
        echo -e "\e[01;31m${tmpErrMsg}\e[00m"
        exit 1
    elif [ -z "`ls "$vhddDirPath/vHDD/"`" ]; then
        echo -e "amount: 0 totalSize: 0 totalGrainSizeM: 0" > "$vhddDirPath/.pokedex_hddInfo.tmp"
        exit
    fi


    local val
    local tmp tmpVhddInfo prevNumber regexInfo
    local vhddDirName=`basename "$vhddDirPath"`
    local number numNumber name size grainSizeM numGrainSizeM grainSector fileName interfaceInfo
    local amount=0
    local totalSize=0
    local totalGrainSizeM=0
    local vhddInfo=""


    tmpVhddInfo=`ls -l "$vhddDirPath/vHDD" | awk '{ print $9 "+size" $5 }' | sed "1d"`
    regexInfo="\(s\([0-9]\{3\}\)-g\(0008\|0128\|0512\|4064\)\(-\([A-Za-z0-9_]\+\)\)\?\.vmdk\)+size\([1-9][0-9]*\)"

    for val in $tmpVhddInfo
    do
        amount=$(( $amount + 1 ))
        "$_libsh/basesh/runingDot" $amount


        number=`echo "$val" | sed "s/$regexInfo/\2/"`

        if [ "$number" == "000" ] || [ -z "`echo "$val" | grep "$regexInfo"`" ]; then
            tmpErrMsg="[警告] 不明文件。 (\"`echo "$val" | sed "s/\(.*\)+size.*/\1/"`\")"
            echo -e "\e[01;33m${tmpErrMsg}\e[00m"
            exit 1
        fi

        if [ "$prevNumber" == "$number" ]; then
            tmpErrMsg="[錯誤] 存在相同編號的虛擬硬碟。 (`printf "%03d" $number`)"
            echo -e "\e[01;31m${tmpErrMsg}\e[00m"
            exit 1
        fi


        prevNumber="$number"

        fileName=`     echo "$val" | sed "s/$regexInfo/\1/"`
        numNumber=`    echo "$val" | sed "s/$regexInfo/\2/" | sed "s/^0*//"`
        grainSizeM=`   echo "$val" | sed "s/$regexInfo/\3/"`
        numGrainSizeM=`echo "$val" | sed "s/$regexInfo/\3/" | sed "s/^0*//"`
        name=`         echo "$val" | sed "s/$regexInfo/\5/"`
        size=`         echo "$val" | sed "s/$regexInfo/\6/"`

        if [ -z "$name" ]; then name="---"; fi
        grainSector=$(( $numGrainSizeM * 1024 * 2 ))
        interfaceInfo=`printf 'RW %7s SPARSE "%s"' "$grainSector" "../$vhddDirName/vHDD/$fileName"`

        totalSize=$(( $totalSize + $size ))
        totalGrainSizeM=$(( $totalGrainSizeM + $numGrainSizeM ))


        tmp="$number $numNumber $name $size $grainSizeM $numGrainSizeM $grainSector $fileName $interfaceInfo"
        vmdkInfo="$vmdkInfo\n$tmp"
    done

    tmp="amount: $amount totalSize: $totalSize totalGrainSizeM: $totalGrainSizeM"
    echo -e "$vmdkInfo" | sed "1c $tmp" > "$vhddDirPath/.pokedex_hddInfo.tmp"
}


fnMain "$@"

