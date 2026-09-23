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
