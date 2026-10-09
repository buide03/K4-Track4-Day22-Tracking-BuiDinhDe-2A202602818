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

## Đối chiếu sau khi chạy

(Điền sau bước 4: dự đoán nào đúng, dự đoán nào sai, vì sao.)

| Video | Dự đoán đúng? | Thấy gì trên video / số liệu |
|---|---|---|
| video_1 | | |
| video_2 | | |
| video_3 | | |
| video_4 | | |
| video_5 | | |
