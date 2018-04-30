# Raspberry Pi 3
baltoy_devX=/dev/sdX
fdisk $baltoy_devX
  # o
  # n, 1, p, +100M, type: c (W95 FAT32 (LBA))
  # n, 2, p
mkfs.vfat ${baltoy_devX}1
mkfs.ext4 ${baltoy_devX}2
mkdir -p /tmp/Baltoy/boot /tmp/Baltoy/root
mount ${baltoy_devX}1 /tmp/Baltoy/boot
mount ${baltoy_devX}2 /tmp/Baltoy/root

wget https://archlinuxarm.org/platforms/armv8/broadcom/raspberry-pi-3
bsdtar -xpf /home/ArchLinuxARM-rpi-3-latest.tar.gz -C /tmp/Baltoy/root/
sync
mv /tmp/Baltoy/root/boot/* /tmp/Baltoy/boot/


sed -i "s/\(^#\(PasswordAuthentication\) yes\)/\1\n\2 no/" /tmp/Baltoy/root/etc/ssh/sshd_config
seed_sshPub="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsy0pWOiSFsU1HdhtYr6EXJedqPCtPvUsd/A3lc5W5GRaXag1DWwtrm5xDl8Wv2IJBuPmmNEr70PgxE9pEP7FrG/0kXxZzyM8o3y4Sl+s3K0JFUpezrsWyF3ZEWMthOGEaL//CLEL/H0NRT4MpuS+bIslTAyW3uSzYevdDs5y++iaQTuDZ8+OefrRSjP7dEXXRxskmxUbjmK4bXuFyCmeiznlOvmUuCzwVgcKDxmPRWN6d7e2Cav0LghqeFtEe2SX1nO4q+pOgrPzjYno9nnegOpNUA1Ip1pjOT3qtzTi6gZCIE9UDKN3g603zywQBk4NUngJpP0rnmgD8DOwH7/ab seed@asand.sea"
mkdir /tmp/Baltoy/root/root/.ssh
echo "$seed_sshPub" > /tmp/Baltoy/root/root/.ssh/authorized_keys
chmod 700 /tmp/Baltoy/root/root/.ssh/
chmod 600 /tmp/Baltoy/root/root/.ssh/authorized_keys

umount /tmp/Baltoy/boot/ /tmp/Baltoy/root/
rm -rf /tmp/Baltoy/


## Login as the default user 
# root password is root.
# alarm password is alarm.


# vim 為主要編輯器
pacman -Rs --noconfirm vi nano
ln -s /usr/bin/vim /usr/bin/vi


# 主機名稱
echo Baltoy > /etc/hostname

# 時間
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
pacman -S --noconfirm ntp
ntpdate time.stdtime.gov.tw
# timedatectl 查看時間


pacman -S --noconfirm arch-install-scripts cifs-utils ntfs-3g gptfdisk exfat-utils partclone
pacman -S --noconfirm iw wpa_supplicant
pacman -S --noconfirm sudo git tmux wget tree docker

https://wiki.archlinux.org/index.php/WPA_supplicant
http://inpega.blogspot.tw/2015/09/iw.html
http://blog.topspeedsnail.com/archives/10108

# sudo
visudo
  # %wheel ALL=(ALL)

# WiFi
wpa_passphrase "SSID" "password" > /etc/wpa_supplicant/example.conf
wpa_supplicant -i interface -c /etc/wpa_supplicant/example.conf
wpa_supplicant -B -i interface -c /etc/wpa_supplicant/example.conf
dhcpcd interface

# docker
systemctl enable docker.service


# 用戶
usermod -L root
usermod -L alarm
usermod -l bwaycer -d /home/bwaycer -m alarm
groupmod -n bwaycer alarm
usermod -G wheel,docker bwaycer
# grep bwaycer /etc/passwd /etc/shadow /etc/group
# passwd bwaycer

cp -r .ssh /home/bwaycer/.ssh
chown -R bwaycer.bwaycer /home/bwaycer/.ssh


pacman -Rs --noconfirm vi nano
pacman -Syu --noconfirm

pacman -S --noconfirm ntp
ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime
ntpdate time.stdtime.gov.tw

sed -i "s/^#\(\(en_US\|zh_TW\).UTF-8 UTF-8\)/\1/" /etc/locale.gen
locale-gen
locale | sed "s/\([A-Z_]=\).*/\1\"zh_TW.UTF-8\"/" > /etc/locale.conf
sed -i "s/\(LC_\(TIME\)=\).*/\1\"en_US.UTF-8\"/" /etc/locale.conf

pacman -S --noconfirm bash-completion sudo ntfs-3g vim git docker tree wget
ln -s /usr/bin/vim /usr/bin/vi
visudo
  # %wheel ALL=(ALL) NOPASSWD: ALL

wget https://nodejs.org/dist/v8.9.1/node-v8.9.1-linux-arm64.tar.xz
tar -xJvf node-v8.9.1-linux-arm64.tar.xz --strip-components 1 -C /usr/local/
rm node-v8.9.1-linux-arm64.tar.xz

