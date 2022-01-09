# 簡介

產品詢價與技術問題請聯繫我們: [hipnuctw@gmail.com](mailto:hipnuctw@gmail.com)

線上賣場:https://www.ruten.com.tw/store/hipnuc_tw

| 資料夾            | 說明               |
| ---------------- | ------------------ |
| 01_UserManual | IMU 產品用戶手冊 |
| 02_GUI |IMU 快速上手軟體，圖表呈現、數值、記錄、模組設定功能 |
| 03_Examples |   資料接收程式範例       |
| 04_UsbDrivers | 提供 Windows/Linux 的 USB 驅動 |


### IMU系列產品說明書

- HI221/HI221 Dongle 無線慣性感測器([PDF](https://github.com/avmm9898/hipnuctw_doc/raw/master/01_UserManual/hi221.pdf))
- HI226 六軸慣性感測器([PDF](https://github.com/avmm9898/hipnuctw_doc/raw/master/01_UserManual/hi226.pdf))
- HI229 九軸慣性感測器([PDF](https://github.com/avmm9898/hipnuctw_doc/raw/master/01_UserManual/hi229.pdf))
- CH100 六軸工業級貼片式高精度慣性感測器([PDF](https://github.com/avmm9898/hipnuctw_doc/raw/master/01_UserManual/ch110.pdf))
- CH110 六軸IP67外殼，RS232工業級高精度慣性感測器([PDF](https://github.com/avmm9898/hipnuctw_doc/raw/master/01_UserManual/ch110.pdf))



### IMU 快速上手軟體: 支援 Windows、Linux


[![CHCenter](http://img.youtube.com/vi/BMr5ByL2h8w/0.jpg)](http://www.youtube.com/watch?v=BMr5ByL2h8w "CHCenter")

### [→下載最新版 (Windows)](https://github.com/avmm9898/hipnuctw_doc/raw/master/02_GUI/CHCenter_v1.2.3_win32.zip)

### [→下載最新版 (Linux64)](https://github.com/avmm9898/hipnuctw_doc/raw/master/02_GUI/CHCenter_v1.2.3_linux64.zip)


包含IMU系列產品的 :

- X Y Z 多軸即時數據、波形圖
- 3D 姿態顯示
- CSV 數據紀錄
- 加速度與陀螺儀FFT分析、低通濾波功能，協助分析振動
- 模組參數設定，如採樣率、鮑率、ID、無線節點 GWID


如有發現問題請聯絡 [hipnuctw@gmail.com](mailto:hipnuctw@gmail.com) 

- 如遇上執行 GUI 提示缺少 msvcpXXX.dll 的狀況，請安裝 [VC_redist.x86.exe](https://github.com/avmm9898/hipnuctw_doc/raw/master/02_GUI/VC_redist.x86.exe)
- 如 Windows 系統未成功識別 IMU 裝置，請安裝 [USB驅動包](https://github.com/avmm9898/hipnuctw_doc/raw/master/04_UsbDrivers/win/IMU_2in1_drivers.zip)

### 範例程式與教學

基本接收資料的範例包含以下程式語言與環境(恕不提供免費額外的程式修改服務):
- C#
- Python
- QT C++
- ROS
- STM32
- Ubuntu

Example Code 下載: [連結](https://github.com/avmm9898/hipnuctw_doc/tree/master/03_Examples)






# 常見問題

## A. IMU，VRU，AHRS 基本認識
### 1. 6軸，9軸， IMU，VRU，AHRS 分別指的是什麼?

> 6軸9軸的概念很好理解：說白了就是模組上裝了哪些，多少感測器
>
> 6軸 : 三軸(XYZ)加速度計 + 三軸(XYZ)陀螺儀(也叫角速度感測器)
> 9軸 : 6軸 + 三軸(XYZ)磁場感測器6軸模組可以構成VRU(垂直參考單元)和IMU(慣性測量單元)，9軸模組可以構成AHRS(航姿參考系統)
> IMU: 慣性測量單元，可以輸出加速度和角速度。並不輸出姿態角等其他資訊
> VRU: IMU的基礎上內置姿態解算演算法，可以輸出姿態資訊。
>
> 靜止狀態下加速度計可以測得重力向量並作為參考，所以靜態下俯仰橫滾角不會漂移而且精度比較高，然而由於航向角與重力垂直，沒有絕對參考，水平方向上的航向角誤差會隨著時間慢慢變大，變的越來越不準 。
>
> 當模組運動時，加速度計測量的不僅僅只有重力，還有其他運動加速度(有害加速度)，所以模組運動中是不能用重力向量作為參考修正俯仰橫滾角的。一個簡單的結論就是：如果模組長時間處於大機動狀態，那麼三個歐拉角誤差都會隨時間變大(越來越不準)，一旦靜止，俯仰橫滾角會被重新"拉"回到正確的位置，而航向角因為沒有參考則不會得到校正。
>
> 
>
> AHRS: VRU的基礎上修改演算法，可以解算被測物體的全姿態，包括絕對的航向角(與地磁北極的夾角)，因為要用到地磁感測器，所以必須是9軸模組。另外室內由於地磁場畸變非常嚴重，AHRS 在室內也很難獲得準確的絕對航向角。
> GPS: 美國的全球衛星定位系統：Global Position System 翻譯過來就叫全球衛星定位系統。
> GNSS: 全球衛星定位系統，GPS，北斗，GLONASS 等系統的總稱，每一個系統叫做一個"星座"GNSS/INS: 衛星/慣導組合導航系統



## B. 性能相關

### 1. IMU，VRU 和 AHRS 的性能與侷限

IMU: 

> 慣性測量單元，可以輸出加速度和角速度。並不輸出姿態角等其他資訊

VRU:

> IMU的基礎上內置姿態解算算法，可以輸出姿態資訊。
>
> 靜止狀態下加速度計可以測得重力向量並作為參考，所以靜態下俯仰橫滾角不會漂移而且精度比較高，然而由於航向角與重力垂直，沒有絕對參考，水平方向上的航向角誤差會隨著時間慢慢變大，變的越來越不准 。
>
> 當模組運動時，加速度計測量的不僅僅只有重力，還有其他運動加速度(有害加速度)，所以模組運動中是不能用重力向量作為參考修正俯仰橫滾角的。一個簡單的結論就是：如果模組長時間處於大機動狀態，那麼三個歐拉角誤差都會隨時間變大(越來越不準)，一旦靜止，俯仰橫滾角會被重新"拉"回到正確的位置，而航向角因為沒有參考則不會得到校正。

AHRS: 

> VRU的基礎上修改算法，可以解算被測物體的全姿態，包括絕對的航向角(與地磁北極的夾角)，因為要用到地磁感測器，所以必須是9軸模組。另外室內由於地磁場畸變非常嚴重，AHRS 在室內也很難獲得準確的絕對航向角。

### 2. 模組可以積分計算速度和位置麼?

> 理論可以，實際不行(沒有意義)。如果沒有其他方式糾正偏差(比如GPS)，那麼位置會很快發散，比如HI226模組，加速度積分得速度，速度積分得位置。這樣二次積分下來，就算是靜止條件下，1分鐘也會飄移幾十米。高速運動/隨機飄出1KM也是有可能的。 真正純慣性導航解算得到穩定的位姿應用的都是高端IMU(光纖，雷射陀螺儀等)一般都價值不菲。

### 3. 模組會受電機等強磁干擾麼?

> 6軸一點都不會，9軸肯定會，而且非常大。所以9軸模式一般不適用於機器人等周圍有磁性物質的場合。

### 4. 解釋一下航向角飄移現象?

> 6軸模組航向角飄移是**必然的**，只是程度的高低不同而已，演算法無法解決晶片性能的極限。需要注意的是所有姿態模組都需要上電靜止1s左右以獲得陀螺零偏，否則航向角飄移會更嚴重，詳見產品手冊描述。
>
> 9軸模組需要配置為9軸模式，並且地磁經過校準，並且無地磁空間畸變干擾的環境下才能輸出穩定無飄移的航向角，室內環境下：辦公桌周圍，廠房，實驗室，儀器設備旁的區域空間磁場畸變非常嚴重，9軸模式下航向角指北精度一般都比較差，初次使用可以到戶外先測試模組性能，在拿回室內比較。

### 5. 沒有轉台等專業設備，如何簡單快速的定性評估動態精度?

> 一個簡單的定性分析方法：
>
> 將模組水平放置，穩定後拿起模組進行隨機機動運動(慢慢動 不要太劇烈，不要超出陀螺量程)，運動一定時間(1min)後回到水平位置，這時候會發現俯仰橫滾角有一個緩慢的 "回正" 過程。
>
> 這是由於運動中加速度計測量的不再只有重力向量，所以無法提供俯仰橫滾角的絕對參考，只能靠陀螺積分來遞推姿態，隨著時間流逝，純陀螺積分姿態必然會有誤差。
>
> 重新水平放置後，模組處於靜止狀態，加速度計測量的又只有重力向量，所以又可以繼續為俯仰、橫滾角提供絕對參考，所以才有 "回正" 過程。 所以，從"回正"的大小程度(而不是快慢)上就可以簡單比較這塊產品的陀螺儀性能。

## C-1. 疑問 : 無線 HI221節點 / HI221接收機

### 1. 無線接收機會互相干擾嗎?

> 無線接收機接收所設定的 GWID 頻段內在線的所有節點，並根據節點自己的 ID 來區分節點。
>
> 若使用者已經依照說明書設定不同無線頻段 (GWID)，每組接收機距離超過 5 米以上，干擾機會小。幾項建議:
>
> 1. 5 米範圍內不建議使用超過 2 組無線接收機
> 2. 建議每組接收機與配對節點之間距離相近，例如 `GWID=1` 的接收機與節點距離最近，避免跟 `GWID=2` 的節點距離最近。

### 2. 無線接收機的設定與最大接收幀率?

> 取決於所設定之波特率。當接收機波特率設定為最大 921600，可連接 8 顆 100Hz 之 HI221，16 顆 50Hz 之 HI221。

### 3. 陀螺儀對振動的敏感度

> 非常敏感，理論上來講陀螺對加速度應該是不敏感的(一個測量角速度，一個測量加速度)，但實際上MEMS器件並非如此(完美)。陀螺對加速度(振動)也是敏感的，並且叫做，"重力敏感度或G敏感性"。這些指標實際上比零偏穩定性還要重要的多，對於振動場合，低成本IMU的表現相較於光纖陀螺和高端MEMS要差的多(其他指標相同的情況下），實際上光纖陀螺因為測量原理不同，壓根沒有這個振動敏感性指標)。例如：IMU周圍有振動源(風扇)，這會極大的影響IMU的輸出數據的精度。

### 4.波特率配置錯誤怎麼辦？

> 模組波特率只可能為：9600, 115200, 256000,460800,921600, 1000000. 輸入任何其他的波特率都無效，如果忘記了之前的波特率，一個一個試下即可。

