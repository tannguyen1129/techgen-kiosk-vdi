#!/bin/bash
# IP Server Nộp bài (UMTOJ)
UMTOJ_IP="203.210.213.198"

# 1. Cho phép traffic nội bộ (QUAN TRỌNG: Để Firefox chạy được IDE)
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT

# 2. Cho phép kết nối đã thiết lập (Để trình duyệt load web mượt)
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# 3. Cho phép truy cập Web Nộp bài (HTTP/HTTPS)
iptables -A OUTPUT -d $UMTOJ_IP -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -d $UMTOJ_IP -p tcp --dport 443 -j ACCEPT

# 4. Chặn tất cả kết nối ra ngoài còn lại (Google, ChatGPT...)
iptables -P OUTPUT DROP