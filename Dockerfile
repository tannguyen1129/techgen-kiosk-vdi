# Base image code-server (Debian Bookworm)
FROM codercom/code-server:latest

USER root

# 1. CÀI ĐẶT GIAO DIỆN & DRIVER
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
    xorgxrdp \
    dbus-x11 \
    xserver-xorg-legacy \
    xserver-xorg-core \
    x11-xserver-utils \
    x11-apps \
    x11-session-utils \
    xfonts-base \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-scalable \
    firefox-esr \
    build-essential \
    gdb \
    python3 \
    python3-pip \
    iptables \
    sudo \
    wget \
    curl \
    nano \
    ssl-cert \
    && rm -rf /var/lib/apt/lists/*

# 2. CẤU HÌNH QUYỀN XORG
RUN echo "allowed_users=anybody" > /etc/X11/Xwrapper.config

# 3. CÀI JAVA 21
RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz -O /tmp/jdk21.tar.gz \
    && mkdir -p /usr/lib/jvm/jdk-21 \
    && tar -xzf /tmp/jdk21.tar.gz -C /usr/lib/jvm/jdk-21 --strip-components=1 \
    && rm /tmp/jdk21.tar.gz \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-21/bin/java 1 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-21/bin/javac 1
ENV JAVA_HOME=/usr/lib/jvm/jdk-21
ENV PATH=$JAVA_HOME/bin:$PATH

# 4. SETUP SCRIPTS
COPY firewall.sh /usr/bin/firewall.sh
COPY entrypoint.sh /usr/bin/kiosk-entrypoint.sh
COPY spy.js /tmp/spy.js
COPY inject_spy.py /tmp/inject_spy.py

RUN chmod +x /usr/bin/firewall.sh /usr/bin/kiosk-entrypoint.sh \
    && python3 /tmp/inject_spy.py && rm /tmp/inject_spy.py

# [QUAN TRỌNG] Mở cổng 3389 trong Firewall
RUN sed -i '2i iptables -I INPUT -p tcp --dport 3389 -j ACCEPT' /usr/bin/firewall.sh

# 5. CẤU HÌNH RDP (FIX LỖI DISCONNECT)
RUN echo "coder:techgen2024" | chpasswd
RUN adduser xrdp ssl-cert
RUN xrdp-keygen xrdp auto

# [FIX V14] Quay về crypt_level=none (Ổn định nhất cho Docker)
RUN rm /etc/xrdp/xrdp.ini && printf "[Globals]\n\
address=0.0.0.0\n\
port=3389\n\
security_layer=rdp\n\
crypt_level=none\n\
bitmap_cache=yes\n\
bitmap_compression=yes\n\
allow_channels=true\n\
max_bpp=32\n\
code=0\n\
name=Xorg\n\
lib=libxup.so\n\
ip=127.0.0.1\n\
use_rfx=no\n\
\n\
[Xorg]\n\
name=Xorg\n\
lib=libxup.so\n\
username=ask\n\
password=ask\n\
ip=127.0.0.1\n\
port=-1\n\
code=20\n" > /etc/xrdp/xrdp.ini

# Startwm (Giữ session luôn sáng)
RUN echo "#!/bin/sh\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
unset XDG_RUNTIME_DIR\n\
xset s off > /dev/null 2>&1\n\
xset -dpms > /dev/null 2>&1\n\
xset s noblank > /dev/null 2>&1\n\
exec dbus-launch --exit-with-session startxfce4" > /etc/xrdp/startwm.sh \
    && chmod +x /etc/xrdp/startwm.sh

# 6. KIOSK MODE
ENV MOZ_WEBRENDER=0
ENV MOZ_ACCELERATED=0

RUN mkdir -p /home/coder/.config/autostart && \
    echo '[Desktop Entry]\n\
Type=Application\n\
Name=KioskIDE\n\
Exec=firefox-esr --kiosk --private-window http://127.0.0.1:8080\n\
StartupNotify=false\n\
Terminal=false' > /home/coder/.config/autostart/kiosk.desktop

# 7. QUYỀN HẠN
RUN chown -R coder:coder /home/coder

EXPOSE 3389
ENTRYPOINT ["/usr/bin/kiosk-entrypoint.sh"]