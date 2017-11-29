圖鑑
=======


## 頁籤


* [簡介](#簡介)
* [施行計畫](#施行計畫)



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
  * [ ] [新增](#硬碟-新增)
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

./bin/hdd info <vhddPath>
./bin/hdd info --update <vhddPath>
```



<a id="硬碟-新增"></a>
### 新增


```
./bin/pokedex hdd add <grainInfo>
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

