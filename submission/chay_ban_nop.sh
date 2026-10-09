#!/bin/bash
# Chạy lại bản nộp (đủ frame) cho 5 video với cấu hình đã chọn ở bước 4.
#
# Cách dùng (từ thư mục gốc repo, đã conda activate cv_robotics_lab21):
#   bash submission/chay_ban_nop.sh            # cả 5 video
#   bash submission/chay_ban_nop.sh video_3    # một video
# Không có GPU: DEVICE=cpu bash submission/chay_ban_nop.sh
#
# Kết quả: runs/nop_bai/video_N.txt và video_N_preview.mp4.
set -e

if [ -z "$LAB_DATA" ]; then
  echo "Chưa có biến LAB_DATA. Chạy: source ~/.bashrc  (hoặc export LAB_DATA=/đường/dẫn/lab_data)"
  exit 1
fi
DEVICE=${DEVICE:-cuda:0}

# video  tracker  conf  iou
CAU_HINH="
video_1 botsort 0.3  0.7
video_2 botsort 0.15 0.5
video_3 botsort 0.15 0.7
video_4 botsort 0.15 0.5
video_5 botsort 0.15 0.4
"

echo "$CAU_HINH" | while read -r V T C I; do
  [ -z "$V" ] && continue
  [ -n "$1" ] && [ "$1" != "$V" ] && continue
  echo "== $V: $T conf=$C iou=$I"
  python scripts/run_tracking.py \
    --source "$LAB_DATA/$V/img1" --seq-name "$V" \
    --tracker "$T" --conf "$C" --iou "$I" \
    --out runs/nop_bai --save-video --device "$DEVICE"
done
