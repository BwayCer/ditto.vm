#!/bin/bash
# Archen Archlinux 安裝指南


fnMain_argsInfo="<執行函數名稱>"
fnMain_subCmd=""
fnMain_opt="
      --chroot  <改變目錄>   執行 \`arch-chroot\` 命令。
  -h, --help   幫助。
"
fnMain_subCmd_allowList=""
fnMain_opt_allowList="
  --chroot 1
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
rootDir=`realpath "$_binsh/.."`
fileRelativePath=lib/archlinuxInstallation/$_fileName
logshLogRelativePath=lib/basesh/.logsh.log


opt_chroot=""

fnMain() {
    local tmp opt val

    tmp=`"$_libsh/basesh/parseArgs" getArgs "$0" \
        "$fnMain_subCmd_allowList" "$fnMain_opt_allowList" "$@"`
    case $? in
        0 )
            eval set -- "$tmp"
            ;;
        2 )
            exec "${_fileName}_$@"
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

        case $opt in
            --chroot )
                shift 2
                opt_chroot=$val
                ;;
        esac
    done

    fnMainHandle "$@"
}

fnMainHandle() {
    local chooseFunc
    chooseFunc=$1
    shift

    local allowList execFunc

    allowList=$allowList" fnHandleGrain   fnShowGrainInfo   fnHandleMirrorList "
    allowList=$allowList" fnPacman                                             "
    allowList=$allowList" fnBootProgram   fnBootProgram_uefi                   "

    execFunc=$(fnAllowVal "$allowList" "fn$chooseFunc" 1)
    if [ -z "$execFunc" ]; then
        _logsh error '找不到欲執行的功能。'
        exit 1
    fi

    if [ -n "$opt_chroot" ]; then
        fnArchChroot "$opt_chroot" $chooseFunc "$@"
    else
        $execFunc "$@"
    fi
}


fnAllowVal() {
    local allowList maybeVal caseInsensitive
    allowList=`echo " "$1" "`
    maybeVal=$2
    caseInsensitive=$3

    if [ -z "`echo "$maybeVal" | grep " "`" ]; then
        if [ "$caseInsensitive" != "1" ] && [ -n "`echo "$allowList" | grep " $maybeVal "`" ]; then
            echo "$maybeVal"
        elif [ -n "`echo "$allowList" | grep -i " $maybeVal "`" ]; then
            echo "$allowList" | sed "s/^.* \($maybeVal\) .*$/\1/i"
        fi
    fi
}


fnArchChroot() {
    local mainMount runArgu
    mainMount=$1
    shift
    runArgu="$@"

    local isoRunDir isoRunFile isoLogFile lenLogFile
    isoRunDir=/root/isoRun.tmp
    isoRunFile=$isoRunDir/$fileRelativePath
    isoLogFile=$isoRunDir/$logshLogRelativePath
    lenLogFile=`cat "$rootDir/$logshLogRelativePath" | wc -l`

    _logsh run cp -r "$rootDir" "$mainMount/$isoRunDir"
    _logsh run echo "sh $isoRunFile $runArgu" "|" arch-chroot "$mainMount"
    _logsh run \
        tail -n $(( `cat "$mainMount/$isoLogFile" | wc -l` - $lenLogFile )) \
        "$mainMount/$isoLogFile" \
        ">>" "$rootDir/$logshLogRelativePath"
    _logsh run rm -r "$mainMount/$isoRunDir"
}

fnHandleGrain() {
    local tmp val
    local mkfsList regexAllowArgu
    local grain mkfsCmd mountPath

    mkfsList=$mkfsList" ext2     ext3     ext4  vfat        "
    mkfsList=$mkfsList" btrfs    cramfs   exfat fat  f2fs   "
    mkfsList=$mkfsList" jfs      minix    msdos ntfs nilfs2 "
    mkfsList=$mkfsList" reiserfs reiserfs xfs               "

    regexAllowArgu="^\([^:]\+:\)\{2\}[^:]\+$"

    for val in "$@"
    do
        if [ -z "`echo "$val" | grep "$regexAllowArgu"`" ]; then
            _logsh error '不符合預期的參數。'
            exit 1
        fi
    done

    for val in "$@"
    do
        grain=`    echo "$val" | cut -d ":" -f 1`
        mkfsCmd=`  echo "$val" | cut -d ":" -f 2`
        mountPath=`echo "$val" | cut -d ":" -f 3`

        tmp=$(fnAllowVal "$mkfsList" "$mkfsCmd")
        if [ -n "$tmp" ]; then
            mkfsCmd=mkfs.$tmp
        fi

        if [ ! -d "$mountPath" ]; then
            _logsh run mkdir "$mountPath"
        fi
        _logsh run $mkfsCmd "$grain"
        _logsh run mount "$grain" "$mountPath"
    done
}

fnShowGrainInfo() {
    _logsh run lsblk -o NAME,SIZE,RA,RO,RM,RAND,PARTFLAGS,PARTLABEL,PARTUUID "$@"
    _logsh run lsblk -o NAME,MOUNTPOINT,FSTYPE,LABEL,UUID "$@"
}

fnHandleMirrorList() {
    local mirrorArea
    mirrorArea=$1

    local mirrorFile mirrorList serverList deleteList
    local lineNumber newMirrorList

    mirrorFile=/etc/pacman.d/mirrorlist

    if [ ! -f "$mirrorFile" ]; then
        _logsh error '鏡像表文件不存在。 ('$mirrorFile')'
        exit 1
    fi

    mirrorList=`cat $mirrorFile`
    serverList=`echo -e "$mirrorList" | grep -n -B 1 "^Server = http" | grep "^[0-9]*-"`

    if [ -z "`echo -e "$serverList" | grep -i "$mirrorArea"`" ]; then
        _logsh error '找不到指定鏡像區域。'
        exit 1
    fi

    deleteList=`echo -e "$serverList" | grep -iv "$mirrorArea" | cut -d "-" -f 1`
    newMirrorList=$mirrorList

    for lineNumber in `echo -e "$deleteList" | sort -rn`
    do
        newMirrorList=`echo -e "$newMirrorList" | sed "$lineNumber,$(( $lineNumber + 1 ))d"`
    done

    _logsh run echo "`echo "$newMirrorList" | sed 's/\$\(\w\)/\\\\$\1/g'`" ">" $mirrorFile
    _logsh run cat $mirrorFile
}

fnBootProgram() {
    local mainMount rootGrain chooseBootSystem
    mainMount=$1
    rootGrain=$2
    chooseBootSystem=$3

    if [ -z "$mainMount" ]; then
        _logsh error '缺少跟目錄掛載位置參數。'
        exit 1
    elif [ -z "$rootGrain" ]; then
        _logsh error '缺少跟目錄硬碟位置參數。'
        exit 1
    fi

    local runArgu

    case "$chooseBootSystem" in
        "UEFI" | "uefi" )
            runArgu="bootProgram_uefi $rootGrain"
            ;;
        * )
            _logsh error '不符合預期的開機系統。'
            exit 1
            ;;
    esac

    _logsh run genfstab -U "$mainMount" ">>" "$mainMount/etc/fstab"
    _logsh run cat "$mainMount/etc/fstab"
    fnArchChroot "$mainMount" $runArgu
}
fnBootProgram_uefi() {
    local rootGrain
    rootGrain=$1

    if [ -z "$rootGrain" ]; then
        _logsh error '缺少跟目錄硬碟位置參數。'
        exit 1
    fi

    local partuuid bootMenu

    _logsh run mkinitcpio -p linux
    _logsh run bootctl install
    _logsh run echo -e "default arch\ntimeout 3" ">" /boot/loader/loader.conf
    _logsh run cat /boot/loader/loader.conf

    partuuid=`blkid -s PARTUUID $rootGrain | sed "s/.*PARTUUID=\"\([a-f0-9-]\+\)\"/\1/"`
    bootMenu=$bootMenu"title Archlinux\n"
    bootMenu=$bootMenu"linux /vmlinuz-linux\n"
    bootMenu=$bootMenu"initrd /initramfs-linux.img\n"
    bootMenu=$bootMenu"options root=PARTUUID=$partuuid rw"
    _logsh run echo -e "$bootMenu" ">" /boot/loader/entries/arch.conf
    _logsh run cat /boot/loader/entries/arch.conf
}

fnPacman() {
    local opt
    opt=$1

    if [ -n "`echo "$opt" | grep "^-[A-Za-z0-9_-]\+"`" ]; then
        shift
    else
        opt=""
    fi

    local tmp pkg allowPkg funcPkg otherPkg

    allowPkg=$allowPkg" openssh "

    for pkg in "$@"
    do
        tmp=$(fnAllowVal "$allowPkg" "$pkg")
        if [ -n "$tmp" ]; then
            funcPkg=$funcPkg" fnPacman_$tmp ;"
        else
            otherPkg=$otherPkg" $pkg"
        fi
    done

    if [ -n "$opt" ] && [ -n "$otherPkg" ]; then
        _logsh run pacman $opt --noconfirm $otherPkg
    elif [ -z "$opt" ] && [ -n "$otherPkg" ]; then
        _logsh run pacman -S --noconfirm $otherPkg
    elif [ -n "`echo "$opt" | grep "^-Sy"`" ]; then
        _logsh run pacman $opt --noconfirm
    fi

    if [ -n "$funcPkg" ]; then
        $funcPkg
    fi
}

fnPacman_openssh() {
    local lineNumber

    _logsh run pacman -S --noconfirm openssh

    if [ ! -f /etc/ssh/sshd_config ]; then
        _logsh error '找不到設定文件。 (/etc/ssh/sshd_config)'
        exit 1
    fi

    if [ -z "`grep "^PasswordAuthentication no$" /etc/ssh/sshd_config`" ]; then
        lineNumber=`grep -n "^#PasswordAuthentication yes" /etc/ssh/sshd_config | cut -d ":" -f 1`
        _logsh run sed -i "$(( $lineNumber + 1 ))i PasswordAuthentication no" /etc/ssh/sshd_config
    fi
    _logsh run grep "PasswordAuthentication" /etc/ssh/sshd_config

    _logsh run "$_binsh/createVmPass"
    _logsh run systemctl enable dhcpcd.service
    _logsh run systemctl enable sshd.service
}


fnMain "$@"

