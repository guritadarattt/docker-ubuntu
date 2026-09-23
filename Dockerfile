FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta

# Update dan install package dasar server (tanpa desktop environment)
RUN apt update -y && apt install --no-install-recommends -y \
    # Core system
    init systemd systemd-sysv dbus \
    # Networking tools
    net-tools iproute2 iputils-ping dnsutils traceroute netcat-openbsd \
    curl wget rsync telnet socat nmap tcpdump \
    # SSH & remote
    openssh-server openssh-client \
    # Text editor & utilities
    vim nano less man-db bash-completion \
    # Process & system monitoring
    htop iotop sysstat lsof psmisc procps \
    # File management
    tar gzip bzip2 xz-utils zip unzip p7zip-full \
    # Build essentials
    build-essential gcc g++ make cmake pkg-config \
    # Version control
    git git-lfs \
    # Python
    python3 python3-pip python3-venv python3-dev \
    # Package management
    software-properties-common apt-utils apt-transport-https ca-certificates gnupg lsb-release \
    # Security
    sudo ufw fail2ban \
    # Time & locale
    tzdata locales \
    # Misc essentials
    cron logrotate rsyslog \
    # SSL/TLS
    openssl ca-certificates \
    # Database clients
    mysql-client postgresql-client redis-tools \
    # Web tools
    nginx-light \
    # Archive & compression
    zstd lz4 \
    # Disk utilities
    parted gdisk fdisk e2fsprogs dosfstools \
    # Additional tools
    jq tree file bc debianutils python3-yq \
    && apt clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install yq versi terbaru (Go version dari mikefarah)
RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    -o /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Setup locale
RUN locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Setup SSH
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Set root password (ganti sesuai kebutuhan)
RUN echo 'root:root' | chpasswd

# Setup timezone
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# ==========================================
# SSH BANNER SETUP - GURITA VPS
# ==========================================

# Matikan MOTD default agar banner custom lebih bersih
RUN rm -rf /etc/update-motd.d/* && \
    rm -f /etc/motd /etc/issue /etc/issue.net && \
    touch /etc/motd /etc/issue /etc/issue.net && \
    sed -i 's/^session.*pam_motd.so/#&/' /etc/pam.d/sshd && \
    sed -i 's/#PrintLastLog yes/PrintLastLog no/' /etc/ssh/sshd_config

# Buat script banner GURITA VPS di /etc/profile.d/
RUN BANNER_FILE=/etc/profile.d/gurita-banner.sh && \
    cat > "$BANNER_FILE" <<'EOF'
#!/bin/bash

# ==========================================
# GURITA VPS LOGIN BANNER
# ==========================================

# Hindari banner pada shell non-interaktif
case $- in
    *i*) ;;
    *) return ;;
esac

clear

echo ""
echo "=========================================="
echo "          G U R I T A   V P S"
echo "=========================================="
echo ""
echo "   ____  _   _ ____ ___ _____  _"
echo "  / ___|| | | |  _ \\_ _|_   _|/ \\"
echo " | |  _ | | | | |_) | |  | | / _ \\"
echo " | |_| || |_| |  _ <| |  | |/ ___ \\"
echo "  \\____| \\___/|_| \\_\\_|  |_|_/   \\_\\"
echo ""
echo ""
echo "=========================================="
echo " User     : $(whoami)"
echo " Uptime   : $(uptime -p 2>/dev/null || echo 'N/A')"
echo " Date     : $(date)"
echo "=========================================="
echo ""
EOF
RUN chmod +x /etc/profile.d/gurita-banner.sh

# Banner SSH untuk client sebelum login (pre-auth banner)
RUN printf '\n  GURITA VPS - Authorized Access Only\n\n' > /etc/ssh/banner && \
    echo 'Banner /etc/ssh/banner' >> /etc/ssh/sshd_config

# ==========================================
# END BANNER SETUP
# ==========================================

# Cleanup untuk mengurangi ukuran image
RUN apt autoremove -y && \
    apt autoclean -y && \
    rm -rf /var/lib/apt/lists/* \
           /var/cache/apt/archives/* \
           /tmp/* \
           /var/tmp/* \
           /usr/share/doc/* \
           /usr/share/man/* \
           /usr/share/locale/* \
           /var/log/*.log

# Expose port SSH
EXPOSE 22

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]
