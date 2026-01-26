# Base image code-server (Debian Bookworm)
FROM codercom/code-server:latest

# Chuyển quyền root để cài cắm
USER root

# 1. CÀI ĐẶT GIAO DIỆN & CÔNG CỤ (SỬA LỖI FIREFOX TẠI ĐÂY)
# - Thay 'firefox' bằng 'firefox-esr'
# - build-essential, gdb: Cho C/C++
# - python3: Cho Python
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
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

# 2. CÀI ĐẶT JAVA 21 (Giữ nguyên cho môn Java)
RUN wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz -O /tmp/jdk21.tar.gz \
    && mkdir -p /usr/lib/jvm/jdk-21 \
    && tar -xzf /tmp/jdk21.tar.gz -C /usr/lib/jvm/jdk-21 --strip-components=1 \
    && rm /tmp/jdk21.tar.gz \
    && update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-21/bin/java 1 \
    && update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-21/bin/javac 1
ENV JAVA_HOME=/usr/lib/jvm/jdk-21
ENV PATH=$JAVA_HOME/bin:$PATH

# 3. SETUP SCRIPTS BẢO MẬT
COPY firewall.sh /usr/bin/firewall.sh
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY spy.js /tmp/spy.js
COPY inject_spy.py /tmp/inject_spy.py

# Cấp quyền và tiêm Spy
RUN chmod +x /usr/bin/firewall.sh /usr/bin/entrypoint.sh \
    && python3 /tmp/inject_spy.py && rm /tmp/inject_spy.py

# 4. CẤU HÌNH RDP (XRDP)
RUN sed -i 's/3389/3389/g' /etc/xrdp/xrdp.ini \
    && sed -i 's/max_bpp=32/max_bpp=24/g' /etc/xrdp/xrdp.ini \
    && echo "xfce4-session" > /home/coder/.xsession

# 5. CẤU HÌNH KIOSK MODE (Dùng lệnh firefox-esr)
# Tự động mở trình duyệt Full màn hình trỏ vào Code-Server nội bộ
RUN mkdir -p /home/coder/.config/autostart && \
    echo '[Desktop Entry]\n\
Type=Application\n\
Name=KioskIDE\n\
Exec=firefox-esr --kiosk --private-window http://127.0.0.1:8080\n\
StartupNotify=false\n\
Terminal=false' > /home/coder/.config/autostart/kiosk.desktop

# Trả quyền cho coder
RUN chown -R coder:coder /home/coder

EXPOSE 3389
ENTRYPOINT ["/usr/bin/entrypoint.sh"]