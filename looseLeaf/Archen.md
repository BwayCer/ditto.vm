始祖小鳥
=======


## 頁籤


* [Archlinux x UEFI](#archlinux-x-uefi)



## Archlinux x UEFI


作業系統： **Arch Linux 4.x.x**


```sh
# NAME      Start (sector)   End (sector)    SIZE  FSCode   FSTYPE   MOUNTPOINT
# sda                                        7.3G
# ├─sda1            2048       14682111        7G    8300     ext4   /mnt
# └─sda2        14682112       15206400      256M    EF00     ext4   /mnt/boot


sgdisk --zap-all --clear --mbrtogpt /dev/sda
sgdisk -n      1:2048:14682111  -t 1:8300    /dev/sda
sgdisk -n  2:14682112:15206400  -t 2:EF00 -p /dev/sda


mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

mkdir /mnt/boot
mkfs.vfat /dev/sda2
mount /dev/sda2 /mnt/boot

lsblk -o NAME,SIZE,RA,RO,RM,RAND,PARTFLAGS,PARTLABEL,PARTUUID
lsblk -o NAME,MOUNTPOINT,FSTYPE,LABEL,UUID


# 選擇映射站
# Taiwan：
#   http://ftp.tku.edu.tw/Linux/ArchLinux/$repo/os/$arch
#   http://shadow.ind.ntou.edu.tw/archlinux/$repo/os/$arch
#   http://archlinux.cs.nctu.edu.tw/$repo/os/$arch
#   http://ftp.yzu.edu.tw/Linux/archlinux/$repo/os/$arch
cat /etc/pacman.d/mirrorlist | grep "http://[^/]\+\.tw/.\+" > /etc/pacman.d/mirrorlist
cat /etc/pacman.d/mirrorlist


# 安裝基本程式包
pacstrap /mnt base bash-completion vim


# 建立文件系統列表
# # 根目錄 /dev/sda1
# UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx       /               ext4            rw,relatime,data=ordered        0 1
# # 開機目錄 /dev/sda2
# UUID=xxxx-xxxx          /boot           vfat            rw,relatime,fmask=0022,dmask=0022,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro  0 2
# # 其他目錄
# UUID=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx       /other          ext4            rw,relatime,data=ordered        0 2
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab


# 切換根目錄
arch-chroot /mnt

    # 建立開機映像
    mkinitcpio -p linux

    # 建立開機程式
    bootctl install

    # 建立開機選單
    # PARTUUID=xxx 中的 xxx 請查找 "根目錄" 的 PARTUUID 取代 `blkid -s PARTUUID /dev/sdaX`
    echo -e "default arch\ntimeout 3" > /boot/loader/loader.conf
    rootPartuuid=`blkid -s PARTUUID /dev/sda1 | sed "s/.*PARTUUID=\"\([a-f0-9-]\+\)\"/\1/"`
    echo -e "title Archlinux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=PARTUUID=$rootPartuuid rw" > /boot/loader/entries/arch.conf
    cat /boot/loader/loader.conf
    cat /boot/loader/entries/arch.conf

    exit


umount -R /mnt
systemctl poweroff
```

