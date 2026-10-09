# Báo cáo lab: chọn tracker cho 5 video

**Nhóm:** cá nhân **Thành viên:** Bùi Đình Đề (2A202602818)

Detector cố định: `yolo26n.pt`, ảnh 640 px, Re-ID `osnet_x0_25_msmt17`. Không đổi các mục này trong bài nộp chính.

## 1. Cấu hình đã chọn

Mỗi video: tracker bạn nộp, `conf`, `iou`, điều bạn **nhìn thấy** trên video, và một cấu hình đã thử rồi loại.

| Video | Tracker | conf | iou | Quan sát khi xem video | Đã thử nhưng loại |
|---|---|---|---|---|---|
| video_1 (quảng trường, tĩnh, ban ngày) | botsort | 0.3 | 0.7 | Người gần camera giữ ID ổn định suốt đoạn đi về phía camera. Lỗi chính là bỏ sót đám đông nhỏ ở xa (người ngồi ghế, dưới gốc cây, trước cửa hàng); gần như không có hộp giả trên nền. | `bytetrack` 0.3 / 0.5: giữ ID tốt nhưng bắt ít người hơn, HOTA 26.92 so với 30.00. Hạ `conf` xuống 0.15 không cứu được vì ByteTrack không tạo track mới từ hộp điểm thấp. |
| video_2 (phố đêm, tĩnh, rất đông) | botsort | 0.15 | 0.5 | Phố sáng đèn, camera trên cao. Người gần giữ ID ổn. `conf` 0.15 bắt thêm người nhỏ, ít track vụn hơn; không thấy hộp giả rõ trên đèn hay bóng. Vẫn sót nhiều người nhỏ ở phía trên khung hình. Khi hai người đi qua nhau có lúc tráo ID. Một cặp nam nữ đi sát nhau: người nữ không có hộp suốt đoạn, người nam đổi từ ID 15 sang ID 27 sau khi mất hộp khoảng 4 s. | `bytetrack` 0.3 / 0.5: ít hộp hơn hẳn, sót nhiều người hơn. `strongsort` / `deepocsort` 0.15 (đủ frame): bắt thêm người nhưng số ID gấp đôi, track vụn hơn nhiều. `botsort` 0.5: sót thêm người và nhiều track ngắn hơn. |
| video_3 (camera di động, ảnh nhỏ) | botsort | 0.15 | 0.7 | Người đứng rất gần camera, chồng lên nhau. Người mặc vest và người áo sọc giữ ID. `iou` 0.7 giữ được hộp người đứng sau mà `iou` 0.5 bị NMS xóa; `conf` thấp bắt thêm người nhỏ phía xa. Vẫn thường mất dấu rồi sinh ID mới khi người bị che hoặc camera quay. | `bytetrack` 0.3 / 0.5: ít hộp nhất, dễ mất người khi camera đi. `strongsort` / `deepocsort` / `ocsort` 0.15 / 0.7 (đủ frame): số ID gần gấp đôi, khoảng một nửa số track ngắn dưới 10 frame. `botsort` 0.15 / 0.5: sót người đứng chồng. |
| video_4 (trong nhà, camera di chuyển) | botsort | 0.15 | 0.5 | Camera tiến tới, người phóng to dần. Người áo trắng và người áo đỏ giữ ID qua đoạn đã xem. Xem hết video thấy có hộp giả trên kính phản chiếu nhưng chỉ chớp khoảng 0.5 s rồi mất, không thành track dài. `conf` 0.15 bắt thêm người ở xa. | `botsort` 0.3 / 0.5 (đủ frame): không bỏ được hộp trên kính vì hộp đó có điểm 0.4–0.5, lại làm đứt track người thật (track dưới 15 frame tăng từ 13 lên 23). `botsort` 0.5 / 0.5: sót người ở xa. |
| video_5 (trên xe bus, giao lộ đông) | botsort | 0.15 | 0.4 | Người nhỏ ở hai bên đường; người áo đỏ giữ cùng ID qua đoạn đã xem. `conf` thấp bắt thêm người nhỏ. Vẫn còn track vụn khi xe rung. Lúc xe rẽ (khoảng giây 20–29 trên preview) có một hộp gom hai người đi sát nhau thành một ID, và người ở xa gần như không được nhận. | `bytetrack` 0.3 / 0.5: ít hộp, có một hộp có vẻ nằm trên cột đèn giao thông. `iou` 0.5 / 0.7: không tách được hộp gom hai người. `ocsort` 0.3: số track vụn tương tự nhưng không có Re-ID để nối lại người. |

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

**So với baseline** (`bytetrack` 0.3 / 0.5, đủ frame). `video_1`: HOTA 26.92 → 30.00, MOTA 17.29 → 19.28, IDF1 25.71 → 29.75; đổi lại IDSW tăng 12 → 33 vì theo được nhiều người khó hơn. `video_2` – `video_5` (so bằng mắt và chỉ số đếm trên file kết quả, chi tiết ở `submission/du_doan.md`): cả bốn video bắt được nhiều người hơn baseline; giữ ID tốt hơn rõ ở `video_2` và `video_5` (ít track vụn hơn); ở `video_3` và `video_4` độ ổn định ID gần như ngang baseline, phần cải thiện chủ yếu là bắt thêm người.

## 3. Phân tích

**video_1 (có số).** `botsort` hơn `bytetrack` khoảng 3 điểm HOTA (30.00 so với 26.92), và phần chênh nằm ở phát hiện (DetA 18.4 so với 15.1) chứ không ở giữ ID (AssA 49.1 so với 48.1). Camera đứng yên, ban ngày nên cả hai đều giữ ID tốt cho người gần; lỗi lớn nhất là bỏ sót đám đông nhỏ ở xa (FN 14403, MLR 68%). Hạ `conf` không giúp ByteTrack vì cấu hình mặc định chỉ tạo track mới từ hộp có điểm trên 0.5 (`track_thresh`), hộp điểm thấp hơn chỉ dùng để nối track cũ; BoT-SORT tạo track mới từ điểm 0.21 (`new_track_thresh`) nên có lợi khi hạ `conf`. `ocsort` bắt nhiều người nhất nhưng đổi ID 168 lần nên HOTA thấp nhất: MOTA không tệ nhưng AssA tụt, đúng kiểu lỗi "ID nhảy liên tục".

*Ví dụ cụ thể, ID 14 (người ngồi ghế dưới gốc cây).* Trên video, hộp của người này lúc có lúc không nhưng vẫn mang ID 14, rồi mất hẳn sau khi có người đi ngang che. Track kéo dài frame 33–185 nhưng chỉ có hộp ở 42 frame: người ngồi nhỏ và bị che một phần nên YOLO chỉ cho điểm 0.30–0.46, dao động quanh ngưỡng `conf` 0.3 (lỗi phát hiện, không phải lỗi tracker). ID vẫn giữ được vì BoT-SORT giữ track "lost" tối đa 60 frame (`track_buffer`), dùng Kalman đoán vị trí và Re-ID để nối lại; khoảng mất hộp dài nhất chỉ 39 frame. Sau frame 185, theo nhãn người này chỉ còn thấy khoảng 20% cơ thể trong 415 frame, YOLO không còn phát hiện được, track bị xoá sau 60 frame và không ID nào khác nhận người đó. Kết quả: không có lỗi đổi ID, nhưng người này đóng góp khoảng 550 FN, đúng kiểu lỗi kéo DetA xuống trong khi AssA vẫn ổn; hạ `conf` chỉ giảm được phần chớp tắt, không cứu được đoạn bị che vì giới hạn nằm ở detector.

**video_3 (chỉ xem bằng mắt).** Camera đi bộ cùng đám đông nên người đứng sát camera và che nhau nhiều. Với `bytetrack` track ngắn và ít người được bắt; `botsort` giữ ID của những người lớn trong khung (người mặc vest, người áo sọc) qua cả đoạn đã xem, nhờ có bù chuyển động camera và Re-ID để nối lại người bị che. Đổi `iou` từ 0.5 lên 0.7 là thay đổi rõ nhất ở video này: người chồng lên nhau có hộp trùng nhiều, `iou` thấp làm NMS xóa mất hộp người đứng sau.

**video_5 (chỉ xem bằng mắt).** Camera đặt trên xe bus rung lắc, người nhỏ ở hai bên đường. Tracker chỉ dựa vào chuyển động dự đoán sai vị trí khi khung hình giật, nên `bytetrack` cắt track vụn hơn và có hộp nghi là giả trên cột đèn. `botsort` có bù chuyển động camera và Re-ID nên nối lại được người sau khi rung (người áo đỏ giữ cùng ID), và `conf` 0.15 bắt thêm người nhỏ. Video này vẫn còn nhiều track ngắn, nên đây là cảnh khó nhất trong năm video.

*Ví dụ cụ thể, lúc xe rẽ.* Ở frame 410 (khoảng giây 20.5) hộp ID 103 bao một người nam và một người nữ đi sát nhau, người nữ che một phần người nam. Chạy lại YOLO trên đúng frame đó với `iou` 0.4 / 0.5 / 0.7 và `conf` 0.15 / 0.05 đều chỉ ra một hộp bao cả hai với điểm 0.71; hộp riêng cho người nam chỉ xuất hiện khi `conf` 0.05 và `iou` 0.7, với điểm 0.07. Vậy lỗi nằm ở detector chứ không phải NMS hay tracker, và đổi `iou` không sửa được. Trong đoạn xe rẽ (frame 409–572) cả cảnh dịch ngang khoảng 26 px mỗi frame, gấp ba bình thường; ảnh nhòe làm điểm của người ở xa (vốn chỉ còn 10–20 px khi thu về 640 px) tụt dưới ngưỡng, nên họ gần như không được nhận.

**video_2 (chỉ xem bằng mắt).** Camera tĩnh trên cao, đông người, người nhỏ và mặc đồ tối giống nhau nên Re-ID khó phân biệt khi hai người đi qua nhau, có lúc tráo ID. *Ví dụ cặp nam nữ đi sát nhau:* người nữ chỉ được YOLO cho điểm 0.13–0.18, dưới ngưỡng `conf` hoặc dưới ngưỡng 0.34 mà BoT-SORT cần để tạo track mới, nên không bao giờ có hộp; `iou` 0.7 cũng không thêm được hộp cho cô ấy, nên không phải do NMS. Người nam có ID 15 ở frame 14–92 với điểm chỉ khoảng 0.25, sống được nhờ hộp điểm thấp nối tiếp track đang theo; mất hộp ở frame 93 thì track chuyển sang "lost", mà hộp điểm thấp không nối lại được track lost, nên sau 60 frame ID 15 bị xoá. Đến frame 174 anh ấy lại gần camera, điểm vượt 0.34 và được tạo track mới ID 27 (đổi ID kiểu A). Thử `strongsort`, `deepocsort`, `bytetrack` và `botsort` 0.3 trên đủ 1050 frame: không cấu hình nào vừa bắt đủ người vừa ít tráo ID hơn `botsort` 0.15, nên giữ cấu hình này và ghi nhận đây là giới hạn của detector trên người nhỏ.

## 4. Nếu có thêm thời gian

Tìm frame có hộp giả trên kính ở `video_4` và xem điểm tin cậy của nó để biết có ngưỡng nào tách được hộp giả khỏi người thật không; quét `conf` mịn hơn (0.1–0.25) cho `botsort` trên `video_2`, `video_5`. Phần lớn lỗi còn lại (người nhỏ bị sót, hai người sát nhau thành một hộp) nằm ở detector nano với ảnh 640 px, nên nếu luật cho phép thì thứ đáng thử tiếp là ảnh đầu vào lớn hơn: thử riêng trên một frame của `video_2`, điểm của người nữ bị sót tăng từ 0.13–0.18 lên 0.40–0.60 khi dùng 1280 px. Với `video_2`, thử `iou` 0.7: ở hai chỗ hai người chồng nhau theo chiều sâu (giây 15: người phụ nữ ID 42 đổi thành ID 44; giây 26–28: hộp ID 3 trôi sang người áo xám ID 27), `iou` 0.5 để NMS chỉ giữ một hộp gộp hai người, còn `iou` 0.7 giữ được hộp riêng và sửa cả hai chỗ, đổi lại hộp trùng (một người hai ID) tăng từ 1.0% lên 4.4%. Trên `video_1` cùng thay đổi này tăng HOTA (29.46 → 30.00), nên đây là hướng nên chấm thử tiếp; bài nộp giữ `iou` 0.5.

## Tệp nộp

| Tệp | Nội dung |
|---|---|
| `submission/BAO_CAO.md` | Báo cáo này |
| `submission/video_1.txt` … `submission/video_5.txt` | Kết quả tracking đủ frame, định dạng MOT, cấu hình ở mục 1 |
| `submission/du_doan.md` | Dự đoán trước khi chạy, baseline, nhật ký các lượt thử và đối chiếu |
| `submission/chay_ban_nop.sh` | Chạy lại 5 file kết quả: `bash submission/chay_ban_nop.sh` |

Video xem thử (`runs/nop_bai/video_N_preview.mp4`) không đưa vào repo; chạy lại script với `--save-video` để tạo lại.
