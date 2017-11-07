#!/bin/sh
# 創建虛擬硬碟


__dirname=`dirname $0`
vmdkNames=()
vmdkTypes=()
vmdkStartNums=()
vmdkEndNums=()

chooseName() {
    printf ">> 硬碟名稱 (可選)： "
    read whatName

    case $whatName in
        "" )
            chooseSize ""
            ;;
        * )
            chooseSize "$whatName"
    esac
}

chooseSize() {
    printf ">> 選擇硬碟容量 (1: 512 MB (默認值)； 2: 4064 MB)： "
    read whichSize

    case $whichSize in
        "" | 1 )
            chooseQuantity "$1" "0512M"
            ;;
        2 )
            chooseQuantity "$1" "4064M"
            ;;
        * )
            chooseSize "$1"
    esac
}

chooseQuantity() {
    local startNum endNum defaultNum
    local lenVmdkEndNums=${#vmdkEndNums[@]}

    if [ $lenVmdkEndNums -eq 0 ]; then
        defaultNum=1
    else
        defaultNum=$(( ${vmdkEndNums[ $(( $lenVmdkEndNums - 1 )) ]} + 1 ))
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
    handleOrder "$1" "$2" $startNum $endNum
}

handleOrder() {
    local vmdkName
    local len=${#vmdkTypes[@]}

    vmdkNames[     $len ]="$1"
    vmdkTypes[     $len ]="$2"
    vmdkStartNums[ $len ]=$3
    vmdkEndNums[   $len ]=$4

    if [ -z "$1" ]; then
        vmdkName="null Name"
    else
        vmdkName="$1"
    fi

    if [ $3 -eq $4 ]; then
        echo ">> [紀錄] $len: $vmdkName, $2, $3"
    else
        echo ">> [紀錄] $len: $vmdkName, $2, $3-$4"
    fi

    createVmdk
}

handleResult() {
    local idxA idxB
    local vmdkName vmdkType vmdkStartNum vmdkEndNum
    local fileSector fileSectorM totalFileSectorM
    local fileSource newFileName
    local len=${#vmdkTypes[@]}

    if [ "$1" == "list" ] && [ $len -eq 0 ]; then
        echo
        echo 空 ...
        createVmdk
        return
    fi

    totalFileSectorM=0
    echo

    if [ "$1" == "finish" ]; then
        echo '".vmdk" Info:'
        echo
    fi

    for (( idxA=0 ; idxA < $len ; idxA++ ))
    do
        vmdkName="${vmdkNames[$idxA]}"
        vmdkType="${vmdkTypes[$idxA]}"
        vmdkStartNum=${vmdkStartNums[$idxA]}
        vmdkEndNum=${vmdkEndNums[$idxA]}

        if [ -n "$vmdkName" ]; then
            vmdkName="-$vmdkName"
        fi

        case $vmdkType in
            "0512M" )
                fileSector="1048576"
                fileSectorM=512
                fileSource="$__dirname/sample_vHDD_0512M_s1048576.vmdk"
                ;;
            "4064M" )
                fileSector="8323072"
                fileSectorM=4064
                fileSource="$__dirname/sample_vHDD_4064M_s8323072.vmdk"
                ;;
        esac

        for idxB in $( seq $vmdkStartNum $vmdkEndNum )
        do
            totalFileSectorM=$(( $totalFileSectorM + $fileSectorM ))
            newFileName="vHDD-s`printf '%03d' $idxB`$vmdkName.vmdk"

            if [ "$1" == "finish" ]; then
                echo "RW $fileSector SPARSE \"$newFileName\""
                cp $fileSource $__dirname/$newFileName
            else
                echo -e "size: \t $fileSectorM MB \t new file: $newFileName"
            fi
        done
    done

    if [ "$1" == "finish" ]; then
        echo
        echo "ddb.geometry.cylinders = \"$totalFileSectorM\""
        echo
    else
        echo -e "total: \t $totalFileSectorM MB"
        createVmdk
    fi
}

createVmdk() {
    echo
    printf "創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： "
    read isContinue

    case $isContinue in
        [Yy] | "Yes" | "yes" )
            chooseName
            ;;
        [Nn] | "No" | "no" )
            ;;
        [Ff] | "finish" | "finish" )
            handleResult "finish"
            ;;
        [Ll] | "List" | "list" )
            handleResult "list"
            ;;
        *)
            createVmdk
    esac
}

createVmdk

