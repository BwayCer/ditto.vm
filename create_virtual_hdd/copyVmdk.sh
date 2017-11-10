#!/bin/sh
# 創建虛擬硬碟


# 關於本腳本與所遇問題
# https://gitlab.com/BwayCer/gitVirtualMachine.vmware/tree/Rotom/create_virtual_hdd


__dirname=`dirname $0`
targetDir="$1"
mainVmdkName="$2"

targetDir_forMainVmdk=""
txtMainSampleA='# Disk DescriptorFile
version=1
encoding="Big5"
CID=ffffffff
parentCID=ffffffff
isNativeSnapshot="no"
createType="twoGbMaxExtentSparse"

# Extent description'
txtMainSampleB='
# The Disk Data Base
#DDB

ddb.adapterType = "lsilogic"'
txtMainSampleC='
ddb.longContentID = "ffffffffffffffffffffffffffffffff"
ddb.uuid = "ff ff ff ff ff ff ff ff-ff ff ff ff ff ff ff ff"
ddb.virtualHWVersion = "12"'

fnPrintfClear() {
    local len=$1
    local txt=$2

    local loop=0

    for loop in $( seq 1 $len )
    do
        printf "\b \b"
    done

    if [ -n "$txt" ]; then
        printf "$txt"
    fi
}

fnobjVmdkSample_sector=""
fnobjVmdkSample_sizeM=""
fnobjVmdkSample_source=""
fnobjVmdkSample() {
    local chooseSize="$1"

    local sector sizeM source
    local sampleFilename="$__dirname/sample_vHDD"

    case $chooseSize in
        "0128M" )
            sector=262144
            sizeM=128
            source="${sampleFilename}_128M_s262144.vmdk"
            ;;
        "0512M" )
            sector=1048576
            sizeM=512
            source="${sampleFilename}_0512M_s1048576.vmdk"
            ;;
        "4064M" )
            sector=8323072
            sizeM=4064
            source="${sampleFilename}_4064M_s8323072.vmdk"
            ;;
    esac

    fnobjVmdkSample_sector=$sector
    fnobjVmdkSample_sizeM=$sizeM
    fnobjVmdkSample_source="$source"
}

fnobjCreateList_name=""
fnobjCreateList_type=""
fnobjCreateList_startNum=""
fnobjCreateList_endNum=""
fnobjCreateList_len=0
fnobjCreateList_names=()
fnobjCreateList_types=()
fnobjCreateList_startNums=()
fnobjCreateList_endNums=()
fnobjCreateList() {
    local method=$1

    local idx

    case "$method" in
        "add" )
            idx=${#fnobjCreateList_types[@]}
            fnobjCreateList_names[     $idx ]="$2"
            fnobjCreateList_types[     $idx ]="$3"
            fnobjCreateList_startNums[ $idx ]=$4
            fnobjCreateList_endNums[   $idx ]=$5
            fnobjCreateList_len=$(( $idx + 1 ))
            ;;
        "get" )
            idx=$2
            fnobjCreateList_name="${fnobjCreateList_names[         $idx ]}"
            fnobjCreateList_type="${fnobjCreateList_types[         $idx ]}"
            fnobjCreateList_startNum=${fnobjCreateList_startNums[ $idx ]}
            fnobjCreateList_endNum=${fnobjCreateList_endNums[     $idx ]}
            ;;
    esac
}

fnChooseTargetDir() {
    local wherePath

    if [ -n "$PWD/$targetDir" ]; then
        targetDir_forMainVmdk="../$targetDir/"
        targetDir="$PWD/$targetDir"
        echo "目標目錄： $targetDir"
        return
    fi

    printf "選擇目標目錄 (默認 \"$PWD\")： "
    read wherePath

    if [ -z "$wherePath" ]; then
        targetDir_forMainVmdk=""
        targetDir="$PWD"
    else
        targetDir_forMainVmdk="../$wherePath/"
        targetDir="$PWD/$wherePath"
    fi

    echo ">> 目標目錄： $targetDir"
}

fnNameMainVmdk() {
    local whatName

    if [ -n "$mainVmdkName" ]; then
        echo "硬碟名稱： $mainVmdkName"
        return
    fi

    echo
    printf '命名硬碟名稱 (默認 "vHDD")： '
    read whatName

    if [ -z "$whatName" ]; then
        mainVmdkName="vHDD"
    else
        mainVmdkName="$whatName"
    fi

    echo ">> 硬碟名稱： $mainVmdkName"
}

fnNameVmdk() {
    local whatName

    printf ">> 切分硬碟名稱 (可選)： "
    read whatName

    if [ -z "$whatName" ]; then
        fnChooseSize ""
    else
        fnChooseSize "$whatName"
    fi
}

fnChooseSize() {
    local whichSize allowOver512M

    if [ $fnobjCreateList_len -ne 0 ]; then
        allowOver512M="； 3: 4064 MB"
    fi

    printf ">> 選擇硬碟容量 (1: 128 MB (默認值)； 2: 512 MB$allowOver512M)： "
    read whichSize

    case $whichSize in
        "" | 1 )
            fnChooseQuantity "$1" "0128M"
            ;;
        2 )
            fnChooseQuantity "$1" "0512M"
            ;;
        3 )
            fnChooseQuantity "$1" "4064M"
            ;;
        * )
            fnChooseSize "$1"
    esac
}

fnChooseQuantity() {
    local startNum endNum
    local defaultNum=1

    if [ $fnobjCreateList_len -ne 0 ]; then
        fnobjCreateList "get" $(( $fnobjCreateList_len - 1 ))
        defaultNum=$(( $fnobjCreateList_endNum + 1 ))
    fi

    printf ">> 給定起始編號 (ex: 1； 默認值 $defaultNum)： "
    read startNum
    if [ -z "$startNum" ]; then
        startNum=$defaultNum
    else
        defaultNum=$startNum
    fi

    printf ">> 給定結束編號 (ex: 2； 默認值 $defaultNum)： "
    read endNum
    if [ -z "$endNum" ]; then
        endNum=$defaultNum
    fi

    startNum=$(( $startNum ))
    endNum=$(( $endNum ))
    fnHandleOrder "$1" "$2" $startNum $endNum
}

fnHandleOrder() {
    local reconfirm orderMsg vmdkName range

    if [ -z "$1" ]; then
        vmdkName="null Name"
    else
        vmdkName="$1"
    fi

    if [ $3 -eq $4 ]; then
        range="$3"
    else
        range="$3-$4"
    fi

    orderMsg="$fnobjCreateList_len: $vmdkName, $2, $range"

    printf ">> 提交 $orderMsg (Yes； No (默認))； "
    read reconfirm

    case $reconfirm in
        [Yy] | "Yes" | "yes" )
            fnobjCreateList "add" "$1" "$2" $3 $4
            echo ">> [紀錄] $orderMsg"
            ;;
        * )
            echo ">> 放棄提交"
            ;;
    esac

    fnCreateVmdk
}

fnHandleResult() {
    local method="$1"

    local idxA idxB txtLine createNum createTotal
    local vmdkName vmdkStartNum vmdkEndNum
    local vmdkNum vmdkSector vmdkSizeM totalFileSizeM
    local fileSource newMainVmdkFileName newFileVmdkName

    if [ "$method" == "list" ] && [ $fnobjCreateList_len -eq 0 ]; then
        echo
        echo 空 ...
        fnCreateVmdk
        return
    fi

    totalFileSizeM=0
    echo

    if [ "$method" == "finish" ]; then
        newMainVmdkFileName="$targetDir/$mainVmdkName.vmdk"
        echo "$txtMainSampleA" > "$newMainVmdkFileName"
    fi

    for (( idxA=0 ; idxA < $fnobjCreateList_len ; idxA++ ))
    do
        fnobjCreateList "get" $idxA
        fnobjVmdkSample "$fnobjCreateList_type"
        vmdkName="$fnobjCreateList_name"
        vmdkStartNum=$fnobjCreateList_startNum
        vmdkEndNum=$fnobjCreateList_endNum
        vmdkSector=$fnobjVmdkSample_sector
        vmdkSizeM=$fnobjVmdkSample_sizeM
        fileSource="$fnobjVmdkSample_source"

        if [ -n "$vmdkName" ]; then
            vmdkName="-$vmdkName"
        fi

        createNum=0
        createTotal=$(( $vmdkEndNum - $vmdkStartNum + 1 ))
        for idxB in $( seq $vmdkStartNum $vmdkEndNum )
        do
            createNum=$(( $createNum + 1 ))
            vmdkNum=`printf '%03d' $idxB`

            if [ "$method" == "finish" ]; then
                fnPrintfClear 99
                printf "\r$mainVmdkName%-18s   [%3s/%3s]   %3s %s" "$vmdkName" "$createNum" "$createTotal" "$idxB" "."
            fi

            totalFileSizeM=$(( $totalFileSizeM + $vmdkSizeM ))
            newFileVmdkName="$mainVmdkName-s$vmdkNum$vmdkName.vmdk"

            if [ "$method" == "finish" ]; then
                printf "."
                cp "$fileSource" "$targetDir/$newFileVmdkName"
                printf "."
                printf "RW %7s SPARSE \"%s\"\n" "$vmdkSector" "$targetDir_forMainVmdk$newFileVmdkName" >> "$newMainVmdkFileName"
                fnPrintfClear 3 " OK"
            else
                printf "size:\t%6s MB \t new file: %s\n" "$vmdkSizeM" "$newFileVmdkName"
            fi
        done

        if [ "$method" == "finish" ]; then
            fnPrintfClear 7 "OK"
            printf "\n"
        fi
    done

    if [ "$method" == "finish" ]; then
txtLine="
ddb.geometry.cylinders = \"$totalFileSizeM\"
ddb.geometry.heads = \"64\"
ddb.geometry.sectors = \"32\""

        echo "$txtMainSampleB""$txtLine""$txtMainSampleC" >> "$newMainVmdkFileName"
        echo
        echo
    else
        printf "total:\t%6s MB\n" "$totalFileSizeM"
        fnCreateVmdk
    fi
}

fnCreateVmdk() {
    local isContinue

    echo
    printf "創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： "
    read isContinue

    case $isContinue in
        [Yy] | "Yes" | "yes" )
            fnNameVmdk
            ;;
        [Nn] | "No" | "no" )
            ;;
        [Ff] | "finish" | "finish" )
            if [ ! -d "$targetDir" ]; then
                if [ -e "$targetDir" ]; then
                    rm "$targetDir"
                fi

                mkdir "$targetDir"
            fi

            fnHandleResult "finish"
            ;;
        [Ll] | "List" | "list" )
            fnHandleResult "list"
            ;;
        *)
            fnCreateVmdk
    esac
}

echo
fnChooseTargetDir
fnNameMainVmdk
fnCreateVmdk

