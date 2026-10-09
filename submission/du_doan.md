# Dự đoán trước khi chạy tracker

Viết **trước** bước 3 (baseline). Đây là giả thuyết dựa trên mô tả cảnh và kết quả ở `on_tap_metrics.ipynb`, chưa phải kết luận. Sau bước 4 sẽ đối chiếu với video có vẽ ID (và số HOTA / MOTA / IDF1 của `video_1`) để viết mục 3 — Phân tích của báo cáo.

Cơ sở từ bước 2: frame đầu `video_1` có khoảng 22 người theo nhãn. YOLO26n ra 5 hộp ở `conf=0.5`, 6 hộp ở `conf=0.3`, 14 hộp ở `conf=0.15`. Người nhỏ ở xa bị sót khi `conf` cao.

## video_1 — quảng trường, camera tĩnh, ban ngày, mật độ vừa

- **ByteTrack** có lẽ đủ tốt: camera đứng yên nên mô hình chuyển động (Kalman) đoán vị trí chuẩn. Ánh sáng tốt nên Re-ID (`botsort`) chỉ cải thiện nhẹ, chủ yếu ở lúc hai người cắt nhau.
- Vấn đề chính sẽ là **bỏ sót người nhỏ ở xa**, không phải đổi ID. Hạ `conf` về khoảng 0.15–0.2 có lẽ tăng HOTA / MOTA nhiều hơn là đổi tracker.

## video_2 — phố, camera tĩnh trên cao, ban đêm, rất đông

- Ảnh tối, người nhỏ nên YOLO cho điểm tin cậy thấp. `conf` 0.3 sẽ **sót nhiều người**. Hạ `conf` thì bắt được nhiều hơn nhưng dễ ra hộp giả trên đèn và bóng.
- Re-ID khó phát huy vì người nhỏ, tối, màu áo khó phân biệt. Nhờ camera tĩnh, **ByteTrack** có thể ngang hoặc tốt hơn `botsort` / `strongsort`, và nhanh hơn nhiều trên 1050 frame. Lỗi hay gặp nhất: **ID nhảy khi người chen nhau** (kiểu B).

## video_3 — camera di chuyển, ảnh nhỏ, ít khung hình/giây

- Người dịch chuyển xa giữa hai frame nên tracker chỉ dựa vào chuyển động dễ mất track và cấp ID mới (**đổi ID kiểu A**).
- **`botsort`** có bù chuyển động camera và Re-ID, có lẽ giữ ID tốt hơn ByteTrack. Ảnh nhỏ nên cần `conf` thấp hơn bình thường.

## video_4 — trong nhà, camera tiến tới, kính phản chiếu

- **Bóng phản chiếu trên kính có thể bị YOLO nhận là người**, gây hộp giả, nên không để `conf` thấp.
- Camera tiến tới làm người phóng to dần, mô hình chuyển động dễ lệch. Tracker có Re-ID (`botsort` hoặc `deepocsort`) có lẽ hợp hơn.

## video_5 — trên xe bus, giao lộ đông, rung lắc

- Cảnh khó nhất. Rung lắc làm hộp nhảy giữa các frame, nên ByteTrack sẽ **đổi ID liên tục**.
- **`botsort`** (bù chuyển động camera + Re-ID) có lẽ tốt nhất. Người đi ngang dày đặc ở giao lộ thì Re-ID giúp tránh gán nhầm.

## Tóm tắt

| Video | Dự đoán tracker | Dự đoán conf | Lỗi dự kiến |
|---|---|---|---|
| video_1 | bytetrack | thấp (0.15–0.2) | bỏ sót người xa |
| video_2 | bytetrack | thấp vừa (~0.2) | ID nhảy khi đông, hộp giả do đèn |
| video_3 | botsort | thấp | đổi ID do camera di chuyển và ít khung hình/giây |
| video_4 | botsort / deepocsort | vừa–cao (0.3–0.4) | hộp giả do phản chiếu kính |
| video_5 | botsort | vừa (~0.3) | đổi ID liên tục do rung lắc |

## Baseline (bước 3)

`video_1`, `bytetrack`, `conf=0.3`, `iou=0.5`, 150 frame đầu (`runs/thu_nhanh/`).

Số ước lượng (ghép hộp với nhãn theo IoU ≥ 0.5 trên 150 frame, không phải số TrackEval):

| Chỉ số | Giá trị |
|---|---|
| Hộp / frame | tracker 4.3, nhãn 25.7 |
| Recall | 15.8% |
| Precision | 93.4% (43 hộp giả / 651) |
| Đổi ID | ~1 |
| Recall theo cỡ | người cao ≥ 120 px: 44.6%; người cao < 120 px: 2.7% |
| MOTA ước lượng | ~0.15 |

Nhìn trên video (frame 20, 75, 140):

- Giữ ID ổn: ba người đi về phía camera giữ ID 3, 2, 5 từ frame 20 đến 140. Hai người bên phải (ID 1, 4) giữ ID tới khi ra khỏi khung. Không thấy đổi ID kiểu A hay B.
- Bỏ sót nhiều (kiểu C): người ngồi ghế, người dưới gốc cây, người trước cửa hàng phía sau hầu như không có hộp. Chỉ thỉnh thoảng bắt được một người xa (ID 7 ở frame 75).
- Gần như không có hộp giả trên nền hoặc bóng.

Kết luận: lỗi chính là **phát hiện**, không phải **tracking**. ByteTrack giữ ID tốt cho người YOLO bắt được, nhưng `conf=0.3` loại gần hết người nhỏ ở xa. Bước 4 với `video_1`: giữ `bytetrack`, hạ `conf` về 0.2 rồi 0.15; chạy thêm `botsort` cùng `conf` để so sánh.

## Thử có hệ thống (bước 4)

Các lượt thử nằm ở `runs/thu/<video>_<tracker>_c<conf>_i<iou>[_f150]/`.

### video_1 — chạy đủ 600 frame, chấm bằng `evaluate_practice.py`

| Tracker | conf | iou | HOTA | MOTA | IDF1 | DetA | AssA | IDSW | FP | FN |
|---|---|---|---|---|---|---|---|---|---|---|
| bytetrack | 0.3 | 0.5 | 26.92 | 17.29 | 25.71 | 15.07 | 48.14 | 12 | 107 | 15249 |
| bytetrack | 0.2 | 0.5 | 27.50 | 17.78 | 26.92 | 15.44 | 49.05 | 12 | 115 | 15150 |
| bytetrack | 0.15 | 0.5 | 27.32 | 18.31 | 26.99 | 15.86 | 47.15 | 13 | 118 | 15047 |
| ocsort | 0.15 | 0.5 | 25.88 | 19.52 | 29.05 | 21.62 | 31.56 | 168 | 1485 | 13300 |
| botsort | 0.5 | 0.5 | 27.18 | 15.25 | 24.55 | 14.30 | 51.71 | 10 | 229 | 15509 |
| botsort | 0.3 | 0.5 | 29.46 | 19.80 | 29.34 | 18.09 | 48.24 | 25 | 337 | 14539 |
| botsort | 0.15 | 0.5 | 29.35 | **20.86** | 29.73 | 19.30 | 45.00 | 29 | 506 | 14171 |
| botsort | 0.3 | 0.4 | 29.32 | 19.46 | 29.81 | 17.36 | 49.65 | 19 | 195 | 14751 |
| **botsort** | **0.3** | **0.7** | **30.00** | 19.28 | 29.75 | 18.43 | 49.12 | 33 | 563 | 14403 |
| botsort | 0.15 | 0.7 | 29.67 | 20.45 | **30.05** | 19.50 | 45.52 | 41 | 701 | 14039 |
| deepocsort | 0.3 | 0.5 | 27.40 | 19.76 | 27.80 | 17.84 | 42.26 | 50 | 250 | 14610 |
| strongsort | 0.3 | 0.5 | 28.66 | 19.72 | 29.87 | 17.71 | 46.60 | 40 | 230 | 14647 |

Nhận xét:

- `botsort` hơn `bytetrack` khoảng 2–3 điểm HOTA ở cùng `conf`. Chênh lệch đến từ DetA (bắt được nhiều người hơn), AssA gần như ngang nhau.
- Hạ `conf` gần như không giúp `bytetrack`: FN chỉ giảm từ 15249 xuống 15047. Cấu hình mặc định của ByteTrack trong boxmot có `track_thresh` 0.5, nên hộp dưới ngưỡng đó chỉ dùng để nối track cũ, không tạo track mới. BoT-SORT tạo track mới từ 0.21 (`new_track_thresh`).
- `ocsort` bắt nhiều người nhất (DetA 21.6) nhưng đổi ID 168 lần và AssA tụt còn 31.6. Đây là ví dụ MOTA không thấp mà HOTA lại thấp nhất.
- `conf` 0.5 giữ ID tốt nhất (AssA 51.7, IDSW 10) nhưng sót nhiều người nhất, HOTA tụt về 27.2.
- Chọn `botsort` conf 0.3 iou 0.7 theo HOTA. `botsort` conf 0.15 iou 0.5 có MOTA cao nhất nhưng HOTA thấp hơn một chút.

### video_2 – video_5 — 150 frame, chỉ số thay thế + xem frame 60 và 140

Không có nhãn, nên so bằng chỉ số tự tính trên file kết quả: hộp/frame (nhiều hơn thường là bắt được nhiều người hơn, cần xem video để loại hộp giả), ID/hộp (số ID chia số hộp trung bình mỗi frame; càng thấp càng ít bị cắt vụn track), trung vị độ dài track, và tỉ lệ track ngắn dưới 10 frame.

| Video | Cấu hình | hộp/fr | #ID | ID/hộp | trung vị dài | % < 10 fr |
|---|---|---|---|---|---|---|
| video_2 | bytetrack 0.3 / 0.5 | 8.8 | 16 | 1.8 | 96 | 19% |
| | ocsort 0.3 / 0.5 | 10.6 | 25 | 2.4 | 35 | 20% |
| | botsort 0.3 / 0.5 | 10.3 | 23 | 2.2 | 38 | 22% |
| | **botsort 0.15 / 0.5** | **11.5** | 21 | **1.8** | 53 | **5%** |
| | botsort 0.5 / 0.5 | 7.5 | 14 | 1.9 | 105 | 29% |
| video_3 | bytetrack 0.3 / 0.5 | 3.9 | 18 | 4.6 | 10 | 39% |
| | ocsort 0.3 / 0.5 | 5.3 | 24 | 4.6 | 13 | 38% |
| | botsort 0.3 / 0.5 | 5.1 | 23 | 4.5 | 15 | 39% |
| | botsort 0.15 / 0.5 | 5.7 | 21 | 3.7 | 22 | 33% |
| | **botsort 0.15 / 0.7** | **6.5** | 22 | **3.4** | 22 | **32%** |
| video_4 | bytetrack 0.3 / 0.5 | 5.4 | 15 | 2.8 | 38 | 13% |
| | botsort 0.3 / 0.5 | 6.4 | 18 | 2.8 | 31 | 28% |
| | **botsort 0.15 / 0.5** | **6.9** | 16 | **2.3** | 69 | 19% |
| | botsort 0.5 / 0.5 | 5.8 | 12 | 2.1 | 73 | 0% |
| video_5 | bytetrack 0.3 / 0.5 | 4.5 | 20 | 4.5 | 18 | 30% |
| | ocsort 0.3 / 0.5 | 6.6 | 26 | 4.0 | 26 | 23% |
| | botsort 0.3 / 0.5 | 6.0 | 27 | 4.5 | 19 | 30% |
| | **botsort 0.15 / 0.4** | **6.7** | 26 | **3.9** | 28 | 23% |

Đổi `iou` 0.4 / 0.5 / 0.7 gần như không đổi gì ở `video_2`, `video_4`, `video_5`. Riêng `video_3` (người đứng sát, chồng lên nhau), iou 0.7 cho 6.5 hộp/frame so với 5.7 ở iou 0.5: NMS bớt xóa nhầm hộp của người đứng sau.

Nhìn trên video:

- **video_2**: cảnh đèn đường sáng, không quá tối. Cả hai tracker sót nhiều người nhỏ ở xa phía trên khung hình. Người gần giữ ID ổn. `botsort` 0.15 bắt thêm vài người nhỏ, không thấy hộp giả rõ ràng.
- **video_3**: người rất gần camera. Người mặc vest và người áo sọc giữ ID ở cả hai tracker. `botsort` 0.15 bắt thêm người nhỏ phía xa.
- **video_4**: ở frame 60 và 140 không thấy hộp giả trên kính phản chiếu, kể cả `conf` 0.15. `conf` 0.15 bắt thêm người ở xa so với 0.5. Xem hết bản nộp đủ frame: có hộp giả trên kính, chỉ chớp khoảng 0.5 s rồi mất.

  Chạy thêm đủ 900 frame để kiểm tra nâng `conf` có bỏ được hộp đó không:

  | conf | hộp/frame | track < 15 frame | % track < 10 frame |
  |---|---|---|---|
  | 0.15 | 7.4 | 13 | 16% |
  | 0.25 | 7.2 | 20 | 24% |
  | 0.3 | 6.9 | 23 | 27% |

  Nâng `conf` làm **tăng** track ngắn: các track ngắn có điểm trung bình 0.4–0.8 nên ngưỡng 0.3 không loại được, còn người thật bị che có điểm tụt dưới ngưỡng vài frame nên track bị đứt rồi nhận ID mới. Giữ `conf` 0.15.
- **video_5**: người nhỏ hai bên đường. Người áo đỏ giữ ID 2 ở cả hai cấu hình. ByteTrack có một hộp có vẻ nằm trên cột đèn giao thông (ID 33, frame 140).

### Cấu hình nộp

Chạy lại bằng `bash submission/chay_ban_nop.sh`.

| Video | Tracker | conf | iou | Đã thử nhưng loại |
|---|---|---|---|---|
| video_1 | botsort | 0.3 | 0.7 | bytetrack 0.3 / 0.5: HOTA 26.92, sót người nhiều hơn |
| video_2 | botsort | 0.15 | 0.5 | bytetrack 0.3 / 0.5: ít hộp hơn (8.8 so với 11.5 / frame) |
| video_3 | botsort | 0.15 | 0.7 | bytetrack 0.3 / 0.5: ít hộp nhất, track ngắn (trung vị 10 frame) |
| video_4 | botsort | 0.15 | 0.5 | botsort 0.5 / 0.5: sót người ở xa |
| video_5 | botsort | 0.15 | 0.4 | bytetrack 0.3 / 0.5: ít hộp, có hộp nghi giả trên cột đèn |

## Đối chiếu sau khi chạy

| Video | Dự đoán đúng? | Thấy gì trên video / số liệu |
|---|---|---|
| video_1 | Đúng một nửa. Đúng là lỗi chính là bỏ sót người xa. Sai ở chỗ ByteTrack đủ tốt và hạ conf sẽ giúp nhiều | `botsort` hơn `bytetrack` 2–3 điểm HOTA. Hạ conf không giúp ByteTrack vì `track_thresh` 0.5 bên trong tracker (BoT-SORT: 0.21) |
| video_2 | Sai | Cảnh sáng đèn chứ không quá tối. `botsort` conf 0.15 bắt nhiều người hơn và ít track ngắn hơn ByteTrack |
| video_3 | Đúng | `botsort` conf thấp tốt nhất. Thêm: iou 0.7 giúp giữ người đứng chồng nhau |
| video_4 | Đúng tracker, sai conf | Có hộp giả trên kính như dự đoán nhưng chỉ chớp ~0.5 s. Nâng conf lên 0.3 không bỏ được nó (điểm 0.4–0.5) mà làm đứt track người thật, nên conf 0.15 tốt hơn 0.3–0.4 |
| video_5 | Đúng tracker, sai conf | `botsort` tốt hơn ByteTrack. conf 0.15 bắt thêm người nhỏ hai bên đường |

## Kiểm tra thêm sau khi xem video nộp

Các lượt dưới đây chạy **đủ frame**, chỉ để so sánh (ghi ở `runs/thu/`). Bài nộp không đổi.

### So với baseline (`bytetrack` 0.3 / 0.5, đủ frame)

| Video | Cấu hình | hộp/frame | #ID | ID/hộp | trung vị dài | % < 10 fr |
|---|---|---|---|---|---|---|
| video_2 | baseline | 9.4 | 47 | 5.0 | 177 | 13% |
| | **nộp: botsort 0.15 / 0.5** | **13.2** | 62 | **4.7** | 170 | **6%** |
| video_3 | baseline | 5.1 | 127 | 24.9 | 16 | 32% |
| | **nộp: botsort 0.15 / 0.7** | **6.8** | 165 | 24.1 | 15 | 30% |
| video_4 | baseline | 6.4 | 61 | 9.5 | 79 | 15% |
| | **nộp: botsort 0.15 / 0.5** | **7.4** | 70 | 9.5 | 60 | 16% |
| video_5 | baseline | 2.7 | 62 | 22.9 | 23 | 37% |
| | **nộp: botsort 0.15 / 0.4** | **4.5** | 79 | **17.8** | 31 | **23%** |

- Cả bốn video bắt được nhiều người hơn: +40% (`video_2`), +33% (`video_3`), +16% (`video_4`), +67% (`video_5`).
- Giữ ID tốt hơn rõ ở `video_2` và `video_5` (ID/hộp thấp hơn, track ngắn ít hơn). Ở `video_3` và `video_4` gần như ngang baseline; `video_4` có trung vị độ dài track ngắn hơn (60 so với 79) vì theo thêm người khó.
- `video_1` (TrackEval): HOTA 26.92 → 30.00, MOTA 17.29 → 19.28, IDF1 25.71 → 29.75, IDSW 12 → 33.

### video_2 — tráo ID khi đi qua nhau

| Cấu hình | hộp/frame | #ID | % < 10 fr | trung vị dài | số lần hộp "nhảy" |
|---|---|---|---|---|---|
| **botsort 0.15 / 0.5 (nộp)** | 13.2 | 62 | 6% | 170 | 1 |
| botsort 0.3 / 0.5 | 11.7 | 69 | 19% | 97 | 2 |
| strongsort 0.15 / 0.5 | 16.2 | 121 | 31% | 42 | 22 |
| deepocsort 0.15 / 0.5 | 16.0 | 127 | 28% | 32 | 30 |
| bytetrack 0.15 / 0.5 | 10.1 | 43 | 7% | 189 | 1 |

"Nhảy" là số lần hộp của một ID dịch hơn nửa bề rộng người giữa hai frame liên tiếp. Trên `video_1` chỉ số này xếp hạng cùng thứ tự với IDSW thật (botsort 0.5: 1 / IDSW 10; ocsort 0.15: 47 / IDSW 168) nhưng chỉ bắt được một phần số lần đổi ID. Một chỉ số khác (đổi hướng đột ngột khi chồng hộp) đã thử và bỏ vì không khớp IDSW thật trên `video_1`.

Cặp nam nữ (giây 5–9 trên preview): người nam ID 15 ở frame 14–92 (điểm TB 0.25), mất hộp frame 93–173, xuất hiện lại frame 174 với ID 27 (điểm TB 0.51). BoT-SORT chỉ dùng hộp điểm < 0.34 để nối track đang theo, không nối lại track lost và không tạo track mới; track lost bị xoá sau 60 frame. Người nữ: YOLO cho 0.13 (frame 60) và 0.18 (frame 130), `iou` 0.7 không thêm hộp. Thử riêng ảnh đầu vào 1280 px (không dùng cho bài nộp): điểm lên 0.40–0.60.

### video_3 — mất dấu rồi sinh ID mới

| Cấu hình | hộp/frame | #ID | % < 10 fr | trung vị dài |
|---|---|---|---|---|
| **botsort 0.15 / 0.7 (nộp)** | 6.8 | 165 | 30% | 15 |
| botsort 0.1 / 0.7 | 6.9 | 168 | 32% | 15 |
| botsort 0.25 / 0.7 | 6.5 | 171 | 39% | 15 |
| botsort 0.15 / 0.8 | 7.3 | 181 | 32% | 18 |
| strongsort 0.15 / 0.7 | 7.2 | 291 | 60% | 6 |
| deepocsort 0.15 / 0.7 | 7.3 | 300 | 49% | 10 |
| ocsort 0.15 / 0.7 | 7.4 | 268 | 48% | 12 |
| bytetrack 0.15 / 0.7 | 5.2 | 130 | 30% | 16 |

Chỉ số "nhảy" không dùng được ở video này: xem 6 lần nhảy của bản nộp thì đều do camera quay, hộp người ở mép ảnh hoặc bị che co giãn, hoặc hộp rất nhỏ rung, không lần nào là tráo ID. Nguyên nhân mất dấu: ít khung hình/giây, camera đi và quay, người gần che nhau; `track_buffer` và ngưỡng ghép bị khoá.

### video_5 — hộp gom hai người, mất người xa khi xe rẽ

- Xe rẽ ở frame 409–572 (ước lượng bằng dịch chuyển toàn ảnh giữa hai frame): trung bình 26.4 px/frame, cả video 8.5 px/frame.
- Frame 410, ID 103: một hộp bao hai người đi sát nhau (rộng/cao 0.40, điểm 0.71). YOLO ở `iou` 0.4 / 0.5 / 0.7 với `conf` 0.15 / 0.05 đều chỉ ra một hộp; hộp thứ hai chỉ có ở `conf` 0.05 + `iou` 0.7, điểm 0.07.
- Các hộp rộng bất thường khác trong đoạn rẽ là người sát mép dưới ảnh bị cắt nửa thân, không phải gom hai người.

### video_2 — hai người chồng nhau theo chiều sâu (`iou`)

Quan sát trên bản nộp: giây 15 người phụ nữ áo kem ID 42 đổi thành ID 44 khi đi sau một người khác; giây 26–28 hộp ID 3 (người áo đen sát mép dưới) trôi lên người áo xám ID 27.

Chạy YOLO trên đúng frame: frame 319 với `iou` 0.5 chỉ ra một hộp gộp hai người phụ nữ (0.34), `iou` 0.7 ra thêm hai hộp riêng (0.26, 0.23); frame 558 với `iou` 0.5 chỉ có hộp gộp người áo xám + người áo đen (0.54), `iou` 0.7 có thêm hộp riêng người áo xám (0.41).

| botsort 0.15, đủ frame | hộp/frame | #ID | % < 10 fr | hộp trùng (IoU > 0.7, hai ID) | áo kem | ID 3 |
|---|---|---|---|---|---|---|
| **iou 0.5 (nộp)** | 13.2 | 62 | 6% | 1.0% | đổi ID ở frame 321 | bị trôi sang người áo xám |
| iou 0.6 | 13.4 | 63 | 5% | 2.5% | giữ 1 ID tới frame 527 | chưa xem |
| iou 0.7 | 13.7 | 63 | 5% | 4.4% | giữ 1 ID tới frame 527 | giữ ID 3; người áo xám bị trùng 2 ID |

Đối chiếu `video_1` (có nhãn, botsort 0.3): iou 0.5 → 0.7 làm hộp trùng 7.5% → 13.7% nhưng HOTA 29.46 → 30.00, IDF1 29.34 → 29.75, MOTA 19.80 → 19.28. Bài nộp `video_2` giữ `iou` 0.5.
