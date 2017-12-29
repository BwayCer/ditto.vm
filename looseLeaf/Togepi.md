波克比
=======


## 頁籤


* [虛擬機](#虛擬機)
* [虛擬硬碟](#虛擬硬碟)
* [作業系統](#作業系統)



## 虛擬機


* Other Linux 3.x kernel 64-bit
* UEFI BIOS



## 虛擬硬碟


```sh
./pokedex/hdd.sh add Togepi \
                 GPT:0008:1   \
                     0128:40  \
                boot:0128:2   \
                 opt:0128:8   \
                 var:0128:8   \
           var_cache:0128:16  \
             var_lib:0128:48  \
             var_log:0128:2   \
                root:0128:1   \
                 GPT:0008:999:1

# ./pokedex/hdd.sh info Togepi
# amount: 127, totalSize: 7.9M, totalGrainSize: 15.64G
#
# GPT       (0008)   64.0K   [  1-  1/  1]   [        0 -    16383 /    16384 (  8.0M) ]
# ---       (0128)    2.5M   [  2- 41/ 40]   [    16384 - 10502143 / 10485760 ( 5.00G) ]
# boot      (0128)  128.0K   [ 42- 43/  2]   [ 10502144 - 11026431 /   524288 (256.0M) ]
# opt       (0128)  512.0K   [ 44- 51/  8]   [ 11026432 - 13123583 /  2097152 ( 1.00G) ]
# var       (0128)  512.0K   [ 52- 59/  8]   [ 13123584 - 15220735 /  2097152 ( 1.00G) ]
# var_cache (0128)    1.0M   [ 60- 75/ 16]   [ 15220736 - 19415039 /  4194304 ( 2.00G) ]
# var_lib   (0128)    3.0M   [ 76-123/ 48]   [ 19415040 - 31997951 / 12582912 ( 6.00G) ]
# var_log   (0128)  128.0K   [124-125/  2]   [ 31997952 - 32522239 /   524288 (256.0M) ]
# root      (0128)   64.0K   [126-126/  1]   [ 32522240 - 32784383 /   262144 (128.0M) ]
# GPT       (0008)   64.0K   [999-999/  1]   [ 32784384 - 32800767 /    16384 (  8.0M) ]
```



## 作業系統


作業系統： **Arch Linux 4.x.x**


```sh
# /dev/sda -> Togepi

# NAME      Start (sector)   End (sector)    SIZE  FSCode   FSTYPE   MOUNTPOINT
# sda                                       15.6G
# ├─sda1           16384       10502143        5G    8300     ext4   /mnt
# ├─sda2        10502144       11026431      256M    EF00     ext4   /mnt/boot
# ├─sda3        11026432       13123583        1G    8300     ext4   /mnt/opt
# ├─sda4        13123584       15220735        1G    8300     ext4   /mnt/var
# ├─sda5        15220736       19415039        2G    8300     ext4   /mnt/var/cache
# ├─sda6        19415040       31997951        6G    8300     ext4   /mnt/var/lib
# ├─sda7        31997952       32522239      256M    8300     ext4   /mnt/var/log
# └─sda8        32522240       32784383      128M    8300     ext4   /mnt/root


sgdisk --zap-all --clear --mbrtogpt /dev/sda
sgdisk -n     1:16384:10502143  -t 1:8300  /dev/sda
sgdisk -n  2:10502144:11026431  -t 2:EF00  /dev/sda
sgdisk -n  3:11026432:13123583  -t 3:8300  /dev/sda
sgdisk -n  4:13123584:15220735  -t 4:8300  /dev/sda
sgdisk -n  5:15220736:19415039  -t 5:8300  /dev/sda
sgdisk -n  6:19415040:31997951  -t 6:8300  /dev/sda
sgdisk -n  7:31997952:32522239  -t 7:8300  /dev/sda
sgdisk -n  8:32522240:32784383  -t 8:8300  /dev/sda


mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

mkdir /mnt/boot
mkfs.vfat /dev/sda2
mount /dev/sda2 /mnt/boot

mkdir /mnt/opt
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt/opt/

mkdir /mnt/var
mkfs.ext4 /dev/sda4
mount /dev/sda4 /mnt/var/

mkdir /mnt/var/cache /mnt/var/lib /mnt/var/log
mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda6
mkfs.ext4 /dev/sda7
mount /dev/sda5 /mnt/var/cache/
mount /dev/sda6 /mnt/var/lib/
mount /dev/sda7 /mnt/var/log/

mkdir /mnt/root
mkfs.ext4 /dev/sda8
mount /dev/sda8 /mnt/root


# 選擇映射站
cat /etc/pacman.d/mirrorlist | grep "http://[^/]\+\.tw/.\+" > /etc/pacman.d/mirrorlist


# 安裝基本程式包
pacstrap /mnt base bash-completion vim


# 建立文件系統列表
genfstab -U /mnt >> /mnt/etc/fstab


# 切換根目錄
arch-chroot /mnt

    # 建立開機映像
    mkinitcpio -p linux

    # 建立開機程式
    bootctl install

    # 建立開機選單：
    echo -e "default arch\ntimeout 3" > /boot/loader/loader.conf
    rootPartuuid=`blkid -s PARTUUID /dev/sda1 | sed "s/.*PARTUUID=\"\([a-f0-9-]\+\)\"/\1/"`
    echo -e "title Archlinux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=PARTUUID=$rootPartuuid rw" > /boot/loader/entries/arch.conf


    # 網路與 SSH
    pacman -S --noconfirm openssh
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
    # 建立通用金鑰
    curl https://raw.githubusercontent.com/BwayCer/ditto.vm/Ditto/Ditto/bin/createVmPass | sh
    systemctl enable dhcpcd.service
    systemctl enable sshd.service


    exit


umount -R /mnt
systemctl poweroff
```

