波克比
=======


## 頁籤


* [虛擬機](#虛擬機)
* [虛擬硬碟](#虛擬硬碟)
* [作業系統](#作業系統)
* [環境配置](#環境配置)



## 虛擬機


* Other Linux 3.x kernel 64-bit
* UEFI BIOS



## 虛擬硬碟


```sh
./pokedex/hdd.sh add Togepi \
                 GPT:0008:1   \
                     0128:48  \
                boot:0128:2   \
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
# ---       (0128)    3.0M   [  2- 49/ 48]   [    16384 - 12599295 / 12582912 ( 6.00G) ]
# boot      (0128)  128.0K   [ 50- 51/  2]   [ 12599296 - 13123583 /   524288 (256.0M) ]
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
# ├─sda1           16384       12599295        6G    8300     ext4   /mnt
# ├─sda2        12599296       13123583      256M    EF00     ext4   /mnt/boot
# ├─sda3        13123584       15220735        1G    8300     ext4   /mnt/var
# ├─sda4        15220736       19415039        2G    8300     ext4   /mnt/var/cache
# ├─sda5        19415040       31997951        6G    8300     ext4   /mnt/var/lib
# ├─sda6        31997952       32522239      256M    8300     ext4   /mnt/var/log
# └─sda7        32522240       32784383      128M    8300     ext4   /mnt/root


sgdisk --zap-all --clear --mbrtogpt /dev/sda
sgdisk -n     1:16384:12599295  -t 1:8300  /dev/sda
sgdisk -n  2:12599296:13123583  -t 2:EF00  /dev/sda
sgdisk -n  3:13123584:15220735  -t 3:8300  /dev/sda
sgdisk -n  4:15220736:19415039  -t 4:8300  /dev/sda
sgdisk -n  5:19415040:31997951  -t 5:8300  /dev/sda
sgdisk -n  6:31997952:32522239  -t 6:8300  /dev/sda
sgdisk -n  7:32522240:32784383  -t 7:8300  /dev/sda


mkfs.ext4 /dev/sda1
mount /dev/sda1 /mnt

mkdir /mnt/boot
mkfs.vfat /dev/sda2
mount /dev/sda2 /mnt/boot

mkdir /mnt/var
mkfs.ext4 /dev/sda3
mount /dev/sda3 /mnt/var/

mkdir /mnt/var/cache /mnt/var/lib /mnt/var/log
mkfs.ext4 /dev/sda4
mkfs.ext4 /dev/sda5
mkfs.ext4 /dev/sda6
mount /dev/sda4 /mnt/var/cache/
mount /dev/sda5 /mnt/var/lib/
mount /dev/sda6 /mnt/var/log/

mkdir /mnt/root
mkfs.ext4 /dev/sda7
mount /dev/sda7 /mnt/root



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



## 環境配置


```
# vim 為主要編輯器
pacman -Rs --noconfirm vi nano
ln -s /usr/bin/vim /usr/bin/vi


# 主機名稱
echo Togepi > /etc/hostname

# 時間
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
pacman -S --noconfirm ntp
ntpdate time.stdtime.gov.tw
# timedatectl 查看時間

# 語系
sed -i "s/^#\(\(en_US\|zh_TW\).UTF-8 UTF-8\)/\1/" /etc/locale.gen
locale-gen
locale | sed "s/\([A-Z_]=\).*/\1\"zh_TW.UTF-8\"/" | sed "s/\(LC_\(TIME\)=\).*/\1\"en_US.UTF-8\"/" > /etc/locale.conf
```

```
pacman -S --noconfirm arch-install-scripts cifs-utils ntfs-3g gptfdisk exfat-utils partclone
pacman -S --noconfirm sudo git tmux wget tree docker

# sudo
visudo
  # %wheel ALL=(ALL)

# docker
systemctl enable docker.service


# 用戶
useradd -m -u 1000 -G wheel,docker bwaycer
# grep bwaycer /etc/passwd /etc/shadow /etc/group
passwd bwaycer
```

