創建虛擬硬碟
=======


```
./copyVmdk.sh
```


**未解的問題：**

初次創建創建切分虛擬硬碟時的資料將會影響之後續增的虛擬硬碟，
在 ".vmdk" 設定文件裡有三個值會隨容量變動：

  * `ddb.geometry.cylinders`
  * `ddb.geometry.heads`
  * `ddb.geometry.sectors`

其中第一個變數當初始的虛擬硬碟為 **512 MB** 時，
磁區 sector 與 `ddb.geometry.cylinders` 的比值為 **2048**，
而另外兩項值分別為
`ddb.geometry.heads = "64"` 、 `ddb.geometry.sectors = "32"` ，
為方便計算初始的虛擬硬碟容量選項將受限制。


**範例：**

```
$ ./create_virtual_hdd/copyVmdk.sh [目標目錄] [硬碟名稱]

目標目錄： /cygdrive/c/Cer/share/Driver/Virtual Machine/Rotom/

命名硬碟名稱 (默認 "vHDD")：
>> 硬碟名稱： vHDD

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： y
>> 切分硬碟名稱 (可選)：
>> 選擇硬碟容量 (1: 128 MB (默認值)； 2: 512 MB)：
>> 給定起始編號 (ex: 1； 默認值 1)：
>> 給定結束編號 (ex: 2； 默認值 1)：
>> 提交 0: null Name, 0128M, 1 (Yes； No (默認))； y
>> [紀錄] 0: null Name, 0128M, 1

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： y
>> 切分硬碟名稱 (可選)： root
>> 選擇硬碟容量 (1: 128 MB (默認值)； 2: 512 MB； 3: 4064 MB)： 2
>> 給定起始編號 (ex: 1； 默認值 2)：
>> 給定結束編號 (ex: 2； 默認值 2)： 7
>> 提交 1: root, 0512M, 2-7 (Yes； No (默認))； y
>> [紀錄] 1: root, 0512M, 2-7

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： y
>> 切分硬碟名稱 (可選)： home
>> 選擇硬碟容量 (1: 128 MB (默認值)； 2: 512 MB； 3: 4064 MB)： 3
>> 給定起始編號 (ex: 1； 默認值 8)： 11
>> 給定結束編號 (ex: 2； 默認值 11)： 13
>> 提交 2: home, 4064M, 11-13 (Yes； No (默認))； y
>> [紀錄] 2: home, 4064M, 11-13

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： l

size:      128 MB        new file: vHDD-s001.vmdk
size:      512 MB        new file: vHDD-s002-root.vmdk
size:      512 MB        new file: vHDD-s003-root.vmdk
size:      512 MB        new file: vHDD-s004-root.vmdk
size:      512 MB        new file: vHDD-s005-root.vmdk
size:      512 MB        new file: vHDD-s006-root.vmdk
size:      512 MB        new file: vHDD-s007-root.vmdk
size:     4064 MB        new file: vHDD-s011-home.vmdk
size:     4064 MB        new file: vHDD-s012-home.vmdk
size:     4064 MB        new file: vHDD-s013-home.vmdk
total:   15392 MB

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： f

vHDD                     [  1/  1]   OK
vHDD-root                [  6/  6]   OK
vHDD-home                [  3/  3]   OK


$ ls -A1
vHDD.vmdk
vHDD-s001.vmdk
vHDD-s002-root.vmdk
vHDD-s003-root.vmdk
vHDD-s004-root.vmdk
vHDD-s005-root.vmdk
vHDD-s006-root.vmdk
vHDD-s007-root.vmdk
vHDD-s011-home.vmdk
vHDD-s012-home.vmdk
vHDD-s013-home.vmdk
```

