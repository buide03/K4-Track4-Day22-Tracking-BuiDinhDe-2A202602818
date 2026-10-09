# Báo cáo lab: chọn tracker cho 5 video

**Nhóm:** ………………………… **Thành viên:** …………………………

Detector cố định: `yolo26n.pt`, ảnh 640 px, Re-ID `osnet_x0_25_msmt17`. Không đổi các mục này trong bài nộp chính.

## 1. Cấu hình đã chọn

Mỗi video: tracker bạn nộp, `conf`, `iou`, điều bạn **nhìn thấy** trên video, và một cấu hình đã thử rồi loại.

| Video | Tracker | conf | iou | Quan sát khi xem video | Đã thử nhưng loại |
|---|---|---|---|---|---|
| video_1 (quảng trường, tĩnh, ban ngày) | | | | | |
| video_2 (phố đêm, tĩnh, rất đông) | | | | | |
| video_3 (camera di động, ảnh nhỏ) | | | | | |
| video_4 (trong nhà, camera di chuyển) | | | | | |
| video_5 (trên xe bus, giao lộ đông) | | | | | |

## 2. Số liệu video_1

Dán bảng HOTA / MOTA / IDF1 do `scripts/evaluate_practice.py` in ra.

```
(dán output ở đây)
```

`video_2` đến `video_5` không có nhãn trong gói lab. Không điền số cho các video đó.

## 3. Phân tích

Với **ít nhất hai video** (nên gồm một video bạn chỉ đánh giá bằng mắt), viết 3–5 câu:

- Tracker đã chọn giữ ID tốt hơn, hay ít hộp giả hơn, ở điểm nào bạn nhìn thấy?
- Cảnh đó (đứng yên / chuyển động, đông / thưa, sáng / tối, trong nhà / ngoài trời) khiến tracker này hợp hơn tracker kia như thế nào?

## 4. Nếu có thêm thời gian

Một hoặc hai câu: bạn sẽ thử tiếp điều gì (Re-ID khác, quét `conf` mịn hơn, xem frame gây lỗi…).
