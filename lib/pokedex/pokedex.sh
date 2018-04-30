#!/bin/bash
# 圖鑑


#!/bin/bash
# 樣本腳本


##shStyle 介面函式
# 對外接口 請驗證輸入值
# 禁止介面函式間相互調用 避免全域變數混雜

##shStyle 共享變數

##shStyle 函式庫
# 若有來源者請註記
# 所有功能請在函式範圍內完成 fnLib, fnLib_xxx, rtnLib_xxx
# 僅允許使用 腳本環境、共享變數 的全域物件

##shStyle 腳本環境

##shStyle ###
# 不共享環境、專屬環境或其他分類


##shStyle ###


_originPlace="lib"

_shScript() {
    case "$1" in
    dir ) ;;
    hdd ) _shCmdLevel=1 ;
        case "$2" in
        info ) _shCmdLevel=2 ;;
        add  ) _shCmdLevel=2 ;;
        esac ;;
    machine | mac | mach | machi | machin | machine ) ;;
    host | hos ) ;;
    diff ) ;;
    esac
}


##shStyle 介面函式


fnHelp_main() { echo "# 圖鑑
# vmware 虛擬機操作工具。
[[USAGE]] [多個參數]
[[SUBCMD]]
  dir        製作中...
  hdd        $fnHelp_hdd_briefly
  machine    製作中...
  host       製作中...
  diff       製作中...
[[OPT]]
  -h, --help   幫助。
"; }
fnOpt_main() {
    case "$1" in
        -h | --help ) fnShowHelp ;;
        * ) return 3 ;;
    esac
}
fnMain() {
    fnParseOption

    fnShowHelp
}

fnHelp_hdd_briefly="虛擬硬碟。"
fnHelp_hdd() { echo "# $fnHelp_hdd_briefly
[[USAGE]]
[[SUBCMD]]
  list    製作中...
  info    $fnHelp_hdd_info_briefly
  add     $fnHelp_hdd_add_briefly
  rm      製作中...
[[OPT]]
  -h, --help   幫助。
"; }
fnOpt_hdd() {
    case "$1" in
        -h | --help ) fnShowHelp ;;
        * ) return 3 ;;
    esac
}
fnMain_hdd() {
    fnParseOption

    fnShowHelp
}

fnHelp_hdd_info_briefly="顯示硬碟資訊。"
fnHelp_hdd_info() { echo "# $fnHelp_hdd_info_briefly
[[USAGE]] <vhddPath>
[[OPT]]
      --update   更新。
  -h, --help     幫助。
"; }
fnOpt_hdd_info() {
    case "$1" in
        --update )
            opt_update="--update"
            return 1
            ;;
        -h | --help ) fnShowHelp ;;
        * ) return 3 ;;
    esac
}
fnMain_hdd_info() {
    opt_update=""
    fnParseOption
    "$_dirsh/hdd_info.sh" $opt_update "${_args[@]}"
}

fnHelp_hdd_add_briefly="新增。"
# fnHelp_hdd_add() {}
# fnOpt_hdd_add() {}
fnMain_hdd_add() {
    # fnParseOption
    "$_dirsh/hdd_addVmdk.sh" "$@"
}


##shStyle 共享變數



##shStyle 函式庫


fnPlatformCode() {
    local method="$1"
    local platformCode=$2

    case "$method" in
        get )
            case `uname` in
                *CYGWIN* ) echo 2 ;; # Cygwin
                * )        echo 1 ;; # Linux
            esac
            ;;
        parse )
            case $platformCode in
                3  ) echo "1 2" ;;
                *  ) echo $platformCode ;;
            esac
            ;;
    esac
}

rtnLsList=()
fnLsList() {
    local txt len idx val
    local lsOpt="$1"
    [ "${lsOpt:0:1}" == "-" ] && shift || lsOpt=""

    local list path
    list=()

    for path in "$@"
    do
        txt=`ls $lsOpt -1 $path 2> /dev/null`
        [ $? -ne 0 ] && continue

        len=`ls $lsOpt -1 $path | wc -l`
        [ $len -eq 0 ] && continue

        for idx in `seq 1 $len`
        do
            val=`echo "$txt" | sed -n "${idx}p"`
            list[ ${#list[@]} ]=$val
        done
    done

    rtnLsList=("${list[@]}")
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

