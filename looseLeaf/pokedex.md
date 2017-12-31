圖鑑
=======


## 頁籤


* [簡介](#簡介)
* [施行計畫](#施行計畫)
* [問題集](#問題集)
  * [No.1 切分虛擬硬碟文件與初次創建虛擬硬碟磁區之關係？](#問題集-1)



## 簡介


虛擬機程式的指令整合腳本。



## 施行計畫


* [儲位點目錄](#儲位點目錄)
  * [ ] [顯示列表](#儲位點目錄-顯示列表)
  * [ ] [新增](#儲位點目錄-新增)
  * [ ] [移除](#儲位點目錄-移除)
* [硬碟](#硬碟)
  * [ ] [顯示列表](#硬碟-顯示列表)
  * [x] [顯示硬碟資訊](#硬碟-顯示硬碟資訊)
  * [x] [新增](#硬碟-新增)
  * [ ] [移除](#硬碟-移除)
* [主機殼](#主機殼)
  * [ ] [顯示列表](#主機殼-顯示列表)
  * [ ] [新增](#主機殼-新增)
  * [ ] [移除](#主機殼-移除)
* [虛擬機](#虛擬機)
  * [ ] [顯示列表](#虛擬機-顯示列表)
  * [ ] [新增](#虛擬機-新增)
  * [ ] [移除](#虛擬機-移除)



## 儲位點目錄


<a id="儲位點目錄-顯示列表"></a>
### 顯示列表


```
./bin/pokedex dir list
```



<a id="儲位點目錄-新增"></a>
### 新增


```
./bin/pokedex dir add <name> <dirname>
```



<a id="儲位點目錄-移除"></a>
### 移除


```
./bin/pokedex dir rm <name>
```


## 硬碟


**目錄結構：**

```
 └─┬ 虛擬硬碟目錄
   ├── info.txt
   ├── interface.vmdk
   └─┬ vHDD
     ├── s001-gXXXX-Name.vmdk
     ├── s<編號 (1-999)>-g<單磁區大小 (0008|0128|0512|4064)>[-<磁區名稱 [A-Za-z0-9_]>].vmdk
     ├── ...
     └── s999-gXXXX-Name.vmdk
```



<a id="硬碟-顯示列表"></a>
### 顯示列表


```
./bin/pokedex hdd list
```



<a id="硬碟-顯示硬碟資訊"></a>
### 顯示硬碟資訊


```
# ./bin/pokedex hdd info <name>

./pokedex/hdd.sh info <vhddPath>
./pokedex/hdd.sh info --update <vhddPath>
```



<a id="硬碟-新增"></a>
### 新增


```
# ./bin/pokedex hdd add \
#     [--noconfirm] \
#     <目標目錄> \
#     [<磁區名稱 [A-Za-z0-9_]>] \
#     <單磁區大小 (0008|0128|0512|4064)> \
#     [<起始編號 (1-999)>] \
#     <數量 (1-999)>

# ./bin/pokedex hdd add \
#     [--noconfirm] \
#     <目標目錄> \
#     [<磁區名稱 [A-Za-z0-9_]>:]<單磁區大小 (0008|0128|0512|4064)>:[<起始編號 (1-999)>:]<數量 (1-999)> \
#     [[<磁區名稱>:]<單磁區大小>:[<起始編號>:]<數量> ...]

./pokedex/hdd.sh add \
    [--noconfirm] \
    <目標目錄> \
    [<磁區名稱 [A-Za-z0-9_]>] \
    <單磁區大小 (0008|0128|0512|4064)> \
    [<起始編號 (1-999)>] \
    <數量 (1-999)>

./pokedex/hdd.sh add \
    [--noconfirm] \
    <目標目錄> \
    [<磁區名稱 [A-Za-z0-9_]>:]<單磁區大小 (0008|0128|0512|4064)>:[<起始編號 (1-999)>:]<數量 (1-999)> \
    [[<磁區名稱>:]<單磁區大小>:[<起始編號>:]<數量> ...]
```



<a id="硬碟-移除"></a>
### 移除


```
./bin/pokedex hdd rm <name>
```



## 主機殼


<a id="主機殼-顯示列表"></a>
### 顯示列表


```
./bin/pokedex machine list
```



<a id="主機殼-新增"></a>
### 新增


```
./bin/pokedex machine add <name> --option
```



<a id="主機殼-移除"></a>
### 移除


```
./bin/pokedex machine rm <name> --option
```



## 虛擬機


<a id="虛擬機-顯示列表"></a>
### 顯示列表


```
./bin/pokedex host list
```



<a id="虛擬機-新增"></a>
### 新增


```
./bin/pokedex host new <name> <machineName> <scsiPortX>:<hddNameX>
```



<a id="虛擬機-移除"></a>
### 移除


```
./bin/pokedex host rm <name> --option
./bin/pokedex host rm <name> --noRecord-vmFile
```



### 差異比較


```
./bin/pokedex diff <hostName>
```



## 問題集


<a id="問題集-1"></a>
### 切分虛擬硬碟文件與初次創建虛擬硬碟磁區之關係？


初次創建切分虛擬硬碟時的資料參數會影響後續新增的虛擬硬碟，
在 ".vmdk" 設定文件裡有三個值會隨容量變動：

  * `ddb.geometry.cylinders`
  * `ddb.geometry.heads`
  * `ddb.geometry.sectors`

其中第一個變數當初始的虛擬硬碟小於某數時（目前得知的最大數為 **512 MB**），
`ddb.geometry.cylinders` 與磁區 sector 的比值為 **2048**，
而另外兩項值分別為
`ddb.geometry.heads = "64"` 、 `ddb.geometry.sectors = "32"` 。

