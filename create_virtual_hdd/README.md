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
$ ./copyVmdk.sh

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： y
>> 硬碟名稱 (可選)：
>> 選擇硬碟容量 (1: 512 MB (默認值))：
>> 給定起始編號 (ex: 1； 默認值 1)：
>> 給定結束編號 (ex: 2； 默認值 1)：
>> [紀錄] 0: null Name, 0512M, 1

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： y
>> 硬碟名稱 (可選)： var
>> 選擇硬碟容量 (1: 512 MB (默認值)； 2: 4064 MB)：
>> 給定起始編號 (ex: 1； 默認值 2)：
>> 給定結束編號 (ex: 2； 默認值 2)： 5
>> [紀錄] 1: var, 0512M, 2-5

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： y
>> 硬碟名稱 (可選)： home
>> 選擇硬碟容量 (1: 512 MB (默認值)； 2: 4064 MB)： 2
>> 給定起始編號 (ex: 1； 默認值 6)： 24
>> 給定結束編號 (ex: 2； 默認值 24)：
>> [紀錄] 2: home, 4064M, 24

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： l

size:    512 MB          new file: vHDD-s001.vmdk
size:    512 MB          new file: vHDD-s002-var.vmdk
size:    512 MB          new file: vHDD-s003-var.vmdk
size:    512 MB          new file: vHDD-s004-var.vmdk
size:    512 MB          new file: vHDD-s005-var.vmdk
size:    4064 MB         new file: vHDD-s024-home.vmdk
total:   6624 MB

創建虛擬硬碟 (Yes(y): 創建； Finish(f): 完成； List(l): 查看清單)： f

".vmdk" Info:

RW 1048576 SPARSE "vHDD-s001.vmdk"
RW 1048576 SPARSE "vHDD-s002-var.vmdk"
RW 1048576 SPARSE "vHDD-s003-var.vmdk"
RW 1048576 SPARSE "vHDD-s004-var.vmdk"
RW 1048576 SPARSE "vHDD-s005-var.vmdk"
RW 8323072 SPARSE "vHDD-s024-home.vmdk"

ddb.geometry.cylinders = "6624"
ddb.geometry.heads = "64"
ddb.geometry.sectors = "32"

$ ls -A1
copyVmdk.sh*
README.md*
sample_vHDD_0512M_s1048576.vmdk*
sample_vHDD_4064M_s8323072.vmdk*
vHDD-s001.vmdk*
vHDD-s002-var.vmdk*
vHDD-s003-var.vmdk*
vHDD-s004-var.vmdk*
vHDD-s005-var.vmdk*
vHDD-s024-home.vmdk*
```

