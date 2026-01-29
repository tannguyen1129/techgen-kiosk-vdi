#!/bin/bash

# 1. Khởi động Code-Server (SỬA LẠI DÒNG NÀY)
# Thêm cờ '--auth none' để vào thẳng IDE không cần mật khẩu
echo "[INIT] Starting Cloud IDE..."
su - coder -c "/usr/bin/code-server --bind-addr 127.0.0.1:8080 --auth none /home/coder/project" &

# Đợi 5 giây cho IDE nạp xong
sleep 5

# 2. Bật Tường lửa
echo "[INIT] Starting Firewall..."
sudo /usr/bin/firewall.sh

# 3. Bật XRDP (Fix lỗi service không chạy)
echo "[INIT] Starting VDI Interface..."
rm -rf /var/run/xrdp/xrdp.pid
rm -rf /var/run/xrdp/xrdp-sesman.pid

# Chạy Sesman dưới nền
/usr/sbin/xrdp-sesman &
sleep 2

# Chạy XRDP
echo "[INIT] System Ready!"
/usr/sbin/xrdp -n