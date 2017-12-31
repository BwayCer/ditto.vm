傲骨燕
=======


## 頁籤


* [虛擬硬碟](#虛擬硬碟)
* [環境配置](#環境配置)



## 虛擬硬碟


```sh
./pokedex/hdd.sh add Taillow \
                 GPT:0008:1   \
                home:4064:8  \
                 GPT:0008:999:1

# ./pokedex/hdd.sh info Taillow
amount: 10, totalSize: 4.1M, totalGrainSize: 31.76G

GPT  (0008)   64.0K   [  1-  1/  1]   [        0 -    16383 /    16384 (  8.0M) ]
home (4064)    4.0M   [  2-  9/  8]   [    16384 - 66600959 / 66584576 (31.75G) ]
GPT  (0008)   64.0K   [999-999/  1]   [ 66600960 - 66617343 /    16384 (  8.0M) ]
```



## 環境配置


```sh
# /dev/sdb -> Taillow

# NAME      Start (sector)   End (sector)    SIZE  FSCode   FSTYPE   MOUNTPOINT
# sdb                                       31.8G
# └─sdb1           16384       66600959     31.8G    8300     ext4   /home

sgdisk --zap-all --clear --mbrtogpt /dev/sdb
sgdisk -n  1:16384:66600959  -t 1:8300  /dev/sdb

mkfs.ext4 /dev/sdb1
```

```
uuid=`blkid -s UUID /dev/sdb1 | sed "s/.*UUID=\"\([a-f0-9-]\+\)\"/\1/"`
echo \
"# /dev-Taillow
UUID=$uuid       /home           ext4            rw,relatime,data=ordered        0 2

# /dev-Taillow/.../varLibDocker.img
/home/imgSpace/varLibDocker.ext4.bs32K.img      /var/lib/docker ext4            loop,rw,relatime,data=ordered   0 2

# /dev-Taillow/.../srv.img
/home/imgSpace/srv.ext4.bs32K.img               /srv            ext4            loop,rw,relatime,data=ordered   0 2
" | sudo tee --append /etc/fstab

sudo reboot
```

