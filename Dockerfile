# Base image code-server (Debian Bookworm)
FROM codercom/code-server:latest

USER root

# 1. CÀI ĐẶT GIAO DIỆN & VNC SERVER (Thay thế XRDP bằng TigerVNC)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    dbus-x11 \
    x11-xserver-utils \
    xfonts-base \
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
    && rm -rf /var/lib/apt/lists/*

# 2. CÀI JAVA 21 (Giữ nguyên)
RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz -O /tmp/jdk21.tar.gz \
    && mkdir -p /usr/lib/jvm/jdk-21 \
    && tar -xzf /tmp/jdk21.tar.gz -C /usr/lib/jvm/jdk-21 --strip-components=1 \
    && rm /tmp/jdk21.tar.gz \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-21/bin/java 1 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-21/bin/javac 1
ENV JAVA_HOME=/usr/lib/jvm/jdk-21
ENV PATH=$JAVA_HOME/bin:$PATH

# 3. SETUP SCRIPTS
COPY firewall.sh /usr/bin/firewall.sh
COPY entrypoint.sh /usr/bin/kiosk-entrypoint.sh
COPY spy.js /tmp/spy.js
COPY inject_spy.py /tmp/inject_spy.py

RUN chmod +x /usr/bin/firewall.sh /usr/bin/kiosk-entrypoint.sh \
    && python3 /tmp/inject_spy.py && rm /tmp/inject_spy.py

# 4. CẤU HÌNH VNC
RUN echo "coder:techgen2024" | chpasswd
# Tạo thư mục cấu hình VNC
RUN mkdir -p /home/coder/.vnc && chown coder:coder /home/coder/.vnc

# [QUAN TRỌNG] Script khởi động giao diện XFCE & Firefox
# Khi VNC chạy, nó sẽ gọi file này để bật giao diện
RUN echo "#!/bin/sh\n\
unset SESSION_MANAGER\n\
unset DBUS_SESSION_BUS_ADDRESS\n\
/usr/bin/startxfce4 &\n\
sleep 2\n\
firefox-esr --kiosk http://127.0.0.1:8080 http://203.210.213.198" > /home/coder/.vnc/xstartup \
    && chmod +x /home/coder/.vnc/xstartup && chown coder:coder /home/coder/.vnc/xstartup

# 5. CẤU HÌNH FIREWALL (Mở port VNC 5901)
RUN sed -i '2i iptables -I INPUT -p tcp --dport 5901 -j ACCEPT' /usr/bin/firewall.sh

# 6. QUYỀN HẠN
RUN chown -R coder:coder /home/coder

EXPOSE 5901
ENTRYPOINT ["/usr/bin/kiosk-entrypoint.sh"]