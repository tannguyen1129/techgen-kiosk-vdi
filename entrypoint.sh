#!/bin/bash

# 1. Khởi động Code-Server
echo "[INIT] Starting Cloud IDE..."
su - coder -c "/usr/bin/code-server --bind-addr 127.0.0.1:8080 --auth none /home/coder/project" &
sleep 5

# 2. Bật Tường lửa
echo "[INIT] Starting Firewall..."
sudo /usr/bin/firewall.sh

# 3. Bật VNC Server (QUAN TRỌNG: Thay thế XRDP)
echo "[INIT] Starting VDI Interface (VNC)..."
rm -rf /tmp/.X1-lock /tmp/.X11-unix/X1

# Chạy TigerVNC tại Display :1 (Tương ứng Port 5901)
# -SecurityTypes None: Không cần mật khẩu VNC (Vì Guacamole đã quản lý Auth rồi)
su - coder -c "vncserver :1 -geometry 1920x1080 -depth 24 -SecurityTypes None"

echo "[INIT] System Ready!"
# Giữ container luôn chạy
tail -f /home/coder/.local/share/code-server/coder-logs/code-server-stdout.log