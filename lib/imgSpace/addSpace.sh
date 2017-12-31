#!/bin/bash
# 新增映像空間


fnMain_argsInfo="<映像文件名稱> <格式化類型> <新增文件大小 (單位 MB)>
       <一單位儲存塊大小 128K|32K|32M>"
fnMain_subCmd=""
fnMain_opt="
  -h, --help     幫助。
"
fnMain_subCmd_allowList=""
fnMain_opt_allowList="
 -h --help 0
"


__filename=`realpath "$0"`
_dirsh=`dirname "$__filename"`
_binsh=`realpath "$_dirsh/../../bin"`
_libsh=`realpath "$_dirsh/.."`
_fileName=`basename "$0"`
_logsh() {
    local val msg
    for val in "${@:2}"
    do
        if [ -n "`echo "_$val" | grep " "`" ]; then
            val='"'`echo "_$val" | sed "s/^_//" | sed 's/\([^\\]\)"/\1\\\"/g'`'"'
        fi
        msg=$msg"$val "
    done
    "$_libsh/basesh/logsh" -- "$_fileName" "$1" "$msg"
    if [ $? -eq 1 ]; then exit 1; fi
    return $?
}


fnMain() {
    local tmp opt val

    tmp=`"$_libsh/basesh/parseArgs" getArgs "$0" \
        "$fnMain_subCmd_allowList" "$fnMain_opt_allowList" "$@"`
    case $? in
        0 )
            eval set -- "$tmp"
            ;;
        2 )
            fnSubCmd "$@"
            exit
            ;;
        3 )
            "$_libsh/basesh/parseArgs" showHelp "$fnMain_argsInfo" "$fnMain_subCmd" "$fnMain_opt"
            exit
            ;;
        * )
            _logsh error "錯誤命令， 訊息：\n$tmp"
            exit 1
            ;;
    esac

    while [ -n 1 ]
    do
        opt=$1
        val=$2

        if [ "$opt" == "--" ]; then
            shift
            break
        fi

        # case $opt in
        #     -option )
        #         shift
        #         opt_option=""
        #         ;;
        # esac
    done

    fnMainHandle "$@"
}

fnMainHandle() {
    local chooseName fsType fillSize blockSize
    chooseName="$1"
    fsType="$2"
    fillSize=$3
    blockSize="$4"

    local grainName oneLoopUnitMb loopTimes newImgSpaceName
    grainName=""
    oneLoopUnitMb=0
    loopTimes=0
    newImgSpaceName=""

    fnGrain $blockSize
    blockSize=$rtnGrain_blockSize
    grainName=$rtnGrain_grainName
    oneLoopUnitMb=$rtnGrain_oneLoopUnitMb

    loopTimes=$(( $fillSize / $oneLoopUnitMb ))
    if [ $(( $fillSize % $oneLoopUnitMb )) -gt 0 ]; then loopTimes=$(( $loopTimes + 1 )); fi

    case "$fsType" in
        ext4 )
            _logsh run mkfs.$fsType "$grainName"
            ;;
        * )
            _logsh run $fsType "$grainName"
            fsType=`echo $fsType | sed "s/^mkfs\.//" | sed "s/\./-/g"`
            ;;
    esac

    echo "區塊大小 : $blockSize"
    echo "格式化   : $fsType"
    echo "填充空間 :"
    newImgSpaceName="$_dirsh/$chooseName.$fsType.bs$blockSize.img"
    fnFillSpace $grainName $oneLoopUnitMb $loopTimes $newImgSpaceName
    _logsh txt "執行 $loopTimes 次 \`cat \"$grainName\" >> \"$newImgSpaceName\"\`"

    _logsh run e2fsck -f "$newImgSpaceName"
    _logsh run resize2fs "$newImgSpaceName"
}


rtnGrain_blockSize=""
rtnGrain_grainName=""
rtnGrain_oneLoopUnitMb=""
fnGrain() {
    local blockSize
    blockSize=$1

    local grainName oneLoopUnitMb

    fnCreateGrain() {
        local blockCount
        blockCount=$1

        if [ ! -f "$grainName" ]; then
            _logsh run dd if=/dev/zero of=$grainName bs=$blockSize count=$blockCount
        fi
    }

    case "$blockSize" in
        128K )
            grainName="$_dirsh/grain.bs128K.img"
            fnCreateGrain 64
            oneLoopUnitMb=8
            ;;
        32M )
            grainName="$_dirsh/grain.bs32M.img"
            fnCreateGrain 1
            oneLoopUnitMb=32
            ;;
        * )
            blockSize="32K"
            grainName="$_dirsh/grain.bs32K.img"
            fnCreateGrain 256
            oneLoopUnitMb=8
            ;;
    esac

    rtnGrain_blockSize=$blockSize
    rtnGrain_grainName=$grainName
    rtnGrain_oneLoopUnitMb=$oneLoopUnitMb
}

fnFillSpace() {
    local grainName oneLoopUnitMb loopTimes newImgSpaceName
    grainName="$1"
    oneLoopUnitMb=$2
    loopTimes=$3
    newImgSpaceName="$4"

    # 一點 4 次； 一排 1024 / 8 / 4 = 32 個點

    local loop txtDot
    txtDot=""

    for loop in `seq 1 $loopTimes`
    do
        if [ $(( ( $loop - 1 ) % 4 )) -eq 0 ]
        then
            txtDot="$txtDot."
            printf "."
        fi

        cat "$grainName" >> "$newImgSpaceName"

        if [ $(( $loop % 128 )) -eq 0 ] || [ $loop -eq $loopTimes ]
        then
            printf "\r%-32s %5s M\n" $txtDot $(( $loop * $oneLoopUnitMb ))
            txtDot=""
        fi
    done
}


fnMain "$@"

