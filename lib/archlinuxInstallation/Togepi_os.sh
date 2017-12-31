#!/bin/bash
# 波克比 作業系統安裝


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
    _logsh run sgdisk --zap-all --clear --mbrtogpt /dev/sda
    _logsh run sgdisk -n     1:16384:12599295  -t 1:8300  /dev/sda
    _logsh run sgdisk -n  2:12599296:13123583  -t 2:EF00  /dev/sda
    _logsh run sgdisk -n  3:13123584:15220735  -t 3:8300  /dev/sda
    _logsh run sgdisk -n  4:15220736:19415039  -t 4:8300  /dev/sda
    _logsh run sgdisk -n  5:19415040:31997951  -t 5:8300  /dev/sda
    _logsh run sgdisk -n  6:31997952:32522239  -t 6:8300  /dev/sda
    _logsh run sgdisk -n  7:32522240:32784383  -t 7:8300  /dev/sda

    _logsh run "$_dirsh/Archen_guide.sh" handleGrain \
        /dev/sda1:ext4:/mnt           \
        /dev/sda2:vfat:/mnt/boot      \
        /dev/sda3:ext4:/mnt/var       \
        /dev/sda4:ext4:/mnt/var/cache \
        /dev/sda5:ext4:/mnt/var/lib   \
        /dev/sda6:ext4:/mnt/var/log   \
        /dev/sda7:ext4:/mnt/root


    ls /home/cachePacmanPkg-v4.*.tar > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        _logsh run tar -xvf \
            "`ls /home/cachePacmanPkg-v4.*.tar | sort -rn | sed -n "1p"`" \
            -C /mnt/
    fi

    _logsh run "$_dirsh/Archen_guide.sh" showGrainInfo /dev/sda

    _logsh run "$_dirsh/Archen_guide.sh" handleMirrorList Taiwan

    _logsh run pacstrap /mnt base bash-completion vim

    _logsh run "$_dirsh/Archen_guide.sh" bootprogram /mnt /dev/sda1 uefi

    _logsh run "$_dirsh/Archen_guide.sh" --chroot /mnt pacman openssh
}


fnMain "$@"

