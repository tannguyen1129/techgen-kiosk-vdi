#!/bin/bash

# 1. Khởi động Code-Server
echo "[INIT] Starting Cloud IDE..."
su - coder -c "/usr/bin/code-server --bind-addr 127.0.0.1:8080 --auth none /home/coder/project" &
sleep 5

# 2. Bật Tường lửa
echo "[INIT] Starting Firewall..."
sudo /usr/bin/firewall.sh

# 3. Bật VNC Server
echo "[INIT] Starting VDI Interface (VNC)..."
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# [SỬA LẠI DÒNG NÀY] Thêm --I-KNOW-THIS-IS-INSECURE để TigerVNC chịu chạy
su - coder -c "vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes None -localhost no --I-KNOW-THIS-IS-INSECURE"

echo "[INIT] System Ready!"
tail -f /home/coder/.local/share/code-server/coder-logs/code-server-stdout.log