# Báo cáo lab: chọn tracker cho 5 video

**Nhóm:** cá nhân **Thành viên:** Bùi Đình Đề (2A202602818)

Detector cố định: `yolo26n.pt`, ảnh 640 px, Re-ID `osnet_x0_25_msmt17`. Không đổi các mục này trong bài nộp chính.

## 1. Cấu hình đã chọn

Mỗi video: tracker bạn nộp, `conf`, `iou`, điều bạn **nhìn thấy** trên video, và một cấu hình đã thử rồi loại.

| Video | Tracker | conf | iou | Quan sát khi xem video | Đã thử nhưng loại |
|---|---|---|---|---|---|
| video_1 (quảng trường, tĩnh, ban ngày) | botsort | 0.3 | 0.7 | Người gần camera giữ ID ổn định suốt đoạn đi về phía camera. Lỗi chính là bỏ sót đám đông nhỏ ở xa (người ngồi ghế, dưới gốc cây, trước cửa hàng); gần như không có hộp giả trên nền. | `bytetrack` 0.3 / 0.5: giữ ID tốt nhưng bắt ít người hơn, HOTA 26.92 so với 30.00. Hạ `conf` xuống 0.15 không cứu được vì ByteTrack không tạo track mới từ hộp điểm thấp. |
| video_2 (phố đêm, tĩnh, rất đông) | botsort | 0.15 | 0.5 | Phố sáng đèn, camera trên cao. Người gần giữ ID ổn. `conf` 0.15 bắt thêm người nhỏ, ít track vụn hơn; không thấy hộp giả rõ trên đèn hay bóng. Vẫn sót nhiều người nhỏ ở phía trên khung hình. | `bytetrack` 0.3 / 0.5: ít hộp hơn hẳn, sót nhiều người hơn. `botsort` 0.5: sót thêm người và nhiều track ngắn hơn. |
| video_3 (camera di động, ảnh nhỏ) | botsort | 0.15 | 0.7 | Người đứng rất gần camera, chồng lên nhau. Người mặc vest và người áo sọc giữ ID. `iou` 0.7 giữ được hộp người đứng sau mà `iou` 0.5 bị NMS xóa; `conf` thấp bắt thêm người nhỏ phía xa. | `bytetrack` 0.3 / 0.5: ít hộp nhất, track ngắn nhất, dễ mất người khi camera đi. `botsort` 0.15 / 0.5: sót người đứng chồng. |
| video_4 (trong nhà, camera di chuyển) | botsort | 0.15 | 0.5 | Camera tiến tới, người phóng to dần. Người áo trắng và người áo đỏ giữ ID qua đoạn đã xem. Ở các frame đã xem không thấy hộp giả trên kính phản chiếu dù `conf` thấp. `conf` 0.15 bắt thêm người ở xa. | `botsort` 0.5 / 0.5: ít track vụn nhưng sót người ở xa. `bytetrack` 0.3 / 0.5: bắt ít người hơn. |
| video_5 (trên xe bus, giao lộ đông) | botsort | 0.15 | 0.4 | Người nhỏ ở hai bên đường; người áo đỏ giữ cùng ID qua đoạn đã xem. `conf` thấp bắt thêm người nhỏ. Vẫn còn track vụn khi xe rung. | `bytetrack` 0.3 / 0.5: ít hộp, có một hộp có vẻ nằm trên cột đèn giao thông. `ocsort` 0.3: số track vụn tương tự nhưng không có Re-ID để nối lại người. |

## 2. Số liệu video_1

Dán bảng HOTA / MOTA / IDF1 do `scripts/evaluate_practice.py` in ra.

```
HOTA: nhom01_video1-pedestrian     HOTA      DetA      AssA      DetRe     DetPr     AssRe     AssPr     LocA      OWTA      HOTA(0)   LocA(0)   HOTALocA(0)
video_1                            30.003    18.425    49.123    19.152    75.06     52.446    80.975    83.072    30.625    37.161    76.947    28.595
COMBINED                           30.003    18.425    49.123    19.152    75.06     52.446    80.975    83.072    30.625    37.161    76.947    28.595

CLEAR: nhom01_video1-pedestrian    MOTA      MOTP      MODA      CLR_Re    CLR_Pr    MTR       PTR       MLR       sMOTA     CLR_TP    CLR_FN    CLR_FP    IDSW      MT        PT        ML        Frag
video_1                            19.278    80.82     19.455    22.485    88.125    14.516    17.742    67.742    14.965    4178      14403     563       33        9         11        42        105
COMBINED                           19.278    80.82     19.455    22.485    88.125    14.516    17.742    67.742    14.965    4178      14403     563       33        9         11        42        105

Identity: nhom01_video1-pedestrian IDF1      IDR       IDP       IDTP      IDFN      IDFP
video_1                            29.749    18.67     73.17     3469      15112     1272
COMBINED                           29.749    18.67     73.17     3469      15112     1272
```

So sánh các cấu hình đã thử trên `video_1` (đủ 600 frame):

| Tracker | conf | iou | HOTA | MOTA | IDF1 | IDSW |
|---|---|---|---|---|---|---|
| bytetrack | 0.3 | 0.5 | 26.92 | 17.29 | 25.71 | 12 |
| bytetrack | 0.15 | 0.5 | 27.32 | 18.31 | 26.99 | 13 |
| ocsort | 0.15 | 0.5 | 25.88 | 19.52 | 29.05 | 168 |
| deepocsort | 0.3 | 0.5 | 27.40 | 19.76 | 27.80 | 50 |
| strongsort | 0.3 | 0.5 | 28.66 | 19.72 | 29.87 | 40 |
| botsort | 0.5 | 0.5 | 27.18 | 15.25 | 24.55 | 10 |
| botsort | 0.3 | 0.5 | 29.46 | 19.80 | 29.34 | 25 |
| botsort | 0.15 | 0.5 | 29.35 | 20.86 | 29.73 | 29 |
| **botsort (nộp)** | **0.3** | **0.7** | **30.00** | 19.28 | 29.75 | 33 |

`video_2` đến `video_5` không có nhãn trong gói lab. Không điền số cho các video đó.

## 3. Phân tích

**video_1 (có số).** `botsort` hơn `bytetrack` khoảng 3 điểm HOTA (30.00 so với 26.92), và phần chênh nằm ở phát hiện (DetA 18.4 so với 15.1) chứ không ở giữ ID (AssA 49.1 so với 48.1). Camera đứng yên, ban ngày nên cả hai đều giữ ID tốt cho người gần; lỗi lớn nhất là bỏ sót đám đông nhỏ ở xa (FN 14403, MLR 68%). Hạ `conf` không giúp ByteTrack vì cấu hình mặc định chỉ tạo track mới từ hộp có điểm trên 0.5 (`track_thresh`), hộp điểm thấp hơn chỉ dùng để nối track cũ; BoT-SORT tạo track mới từ điểm 0.21 (`new_track_thresh`) nên có lợi khi hạ `conf`. `ocsort` bắt nhiều người nhất nhưng đổi ID 168 lần nên HOTA thấp nhất: MOTA không tệ nhưng AssA tụt, đúng kiểu lỗi "ID nhảy liên tục".

**video_3 (chỉ xem bằng mắt).** Camera đi bộ cùng đám đông nên người đứng sát camera và che nhau nhiều. Với `bytetrack` track ngắn và ít người được bắt; `botsort` giữ ID của những người lớn trong khung (người mặc vest, người áo sọc) qua cả đoạn đã xem, nhờ có bù chuyển động camera và Re-ID để nối lại người bị che. Đổi `iou` từ 0.5 lên 0.7 là thay đổi rõ nhất ở video này: người chồng lên nhau có hộp trùng nhiều, `iou` thấp làm NMS xóa mất hộp người đứng sau.

**video_5 (chỉ xem bằng mắt).** Camera đặt trên xe bus rung lắc, người nhỏ ở hai bên đường. Tracker chỉ dựa vào chuyển động dự đoán sai vị trí khi khung hình giật, nên `bytetrack` cắt track vụn hơn và có hộp nghi là giả trên cột đèn. `botsort` có bù chuyển động camera và Re-ID nên nối lại được người sau khi rung (người áo đỏ giữ cùng ID), và `conf` 0.15 bắt thêm người nhỏ. Video này vẫn còn nhiều track ngắn, nên đây là cảnh khó nhất trong năm video.

## 4. Nếu có thêm thời gian

Xem hết video preview của `video_4` để chắc `conf` 0.15 không sinh hộp giả trên kính ở đoạn sau, và quét `conf` mịn hơn (0.1–0.25) cho `botsort` trên `video_2`, `video_5`. Thử thêm `strongsort` ở `video_3` và `video_5`, vì trên `video_1` nó có IDF1 ngang `botsort`.
