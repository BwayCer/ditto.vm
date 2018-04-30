#!/bin/sh
# 映像檔開機腳本


# 在虛擬機關機後回復起始狀態


__cwdirname=$PWD
__dirname=`dirname $0`
__filename=`basename $0`
isExitVmplayer=$1

tmpShFilename=".$__filename"
bisExistVmplayer=0
execStart=cygstart
rmList=(
    Ditto.vmsd
    Ditto.vmxf
    vmware.log
    vmware-*.log
)
execCmd=()

which vmplayer > /dev/null 2>&1
if [ $? -eq 0 ]
then
    bisExistVmplayer=1
    execStart=vmplayer
fi

rtnJoinBy=""
fnJoinBy() {
    local separator="$1"; shift
    regex="$( printf "${separator}%s" "$@" )"
    regex="${regex:${#separator}}"
    rtnJoinBy="$regex"
}

fnRmList() {
    local val filePath

    for val in $@
    do
        filePath=$val
        if [ -f $filePath ]
        then
            execCmd[ ${#execCmd[@]} ]="rm $filePath"
        fi
    done
}

fnRestore() {
    fnRmList ${rmList[@]}
    execCmd[ ${#execCmd[@]} ]="git checkout -- ."
}

execCmd[ ${#execCmd[@]} ]="cd '$__dirname'"
fnRestore
if [ "$isExitVmplayer" != "1" ]
then
    execCmd[ ${#execCmd[@]} ]="$execStart Ditto.vmx > /dev/null 2>&1"
    execCmd[ ${#execCmd[@]} ]="sh '$0' 1"
fi

fnJoinBy " ; " "${execCmd[@]}"
sh -c "$rtnJoinBy" &

