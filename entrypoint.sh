#!/bin/bash

# 1. Khởi động Code-Server (Chạy ngầm ở port 8080 nội bộ)
# --bind-addr 127.0.0.1: Quan trọng! Để không ai từ ngoài truy cập được trừ Firefox nội bộ
echo "[INIT] Starting Cloud IDE..."
/usr/bin/entrypoint.sh --bind-addr 127.0.0.1:8080 /home/coder/project &

# Đợi 5 giây cho IDE nạp xong
sleep 5

# 2. Bật Tường lửa (Chặn Internet, chỉ cho nộp bài)
echo "[INIT] Starting Firewall..."
sudo /usr/bin/firewall.sh

# 3. Bật XRDP (Cổng để VDI Gateway kết nối vào)
echo "[INIT] Starting VDI Interface..."
rm -rf /var/run/xrdp/xrdp.pid
rm -rf /var/run/xrdp/xrdp-sesman.pid
sudo service xrdp-sesman start
sudo /usr/sbin/xrdp -n