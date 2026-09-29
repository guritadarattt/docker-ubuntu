# ==========================================
# GURITA VPS - Lightweight Server Container
# Base  : Ubuntu 22.04
# Init  : supervisord (ringan, multi-service)
# ==========================================
FROM --platform=linux/amd64 ubuntu:22.04

# ---------- ENV ----------
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Asia/Jakarta \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8

# ---------- INSTALL PACKAGE ----------
RUN apt-get update -y && apt-get install --no-install-recommends -y \
    supervisor \
    net-tools iproute2 iputils-ping dnsutils traceroute netcat-openbsd \
    curl wget rsync telnet socat \
    openssh-server openssh-client \
    vim-tiny nano less bash-completion \
    htop lsof psmisc procps \
    tar gzip bzip2 xz-utils zip unzip \
    sudo fail2ban \
    tzdata locales \
    cron logrotate rsyslog \
    openssl ca-certificates \
    jq tree file bc debianutils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# ---------- LOCALE ----------
RUN sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && \
    locale-gen en_US.UTF-8

# ---------- TIMEZONE ----------
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone

# ---------- SSH SETUP ----------
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PrintLastLog yes/PrintLastLog no/' /etc/ssh/sshd_config && \
    sed -i 's/^session.*pam_motd.so/#&/' /etc/pam.d/sshd

# ---------- ROOT PASSWORD ----------
ARG ROOT_PASSWORD=Gurita26
RUN echo "root:${ROOT_PASSWORD}" | chpasswd

# ---------- BANNER (inline) ----------
RUN printf '%s\n' \
    '#!/bin/bash' \
    'case $- in *i*) ;; *) return ;; esac' \
    'clear' \
    'echo ""' \
    'echo "=========================================="' \
    'echo "          G U R I T A   V P S"' \
    'echo "=========================================="' \
    'echo ""' \
    'echo "   ____  _   _ ____ ___ _____  _" ' \
    'echo "  / ___|| | | |  _ \\_ _|_   _|/ \\"' \
    'echo " | |  _ | | | | |_) | |  | | / _ \\"' \
    'echo " | |_| || |_| |  _ <| |  | |/ ___ \\"' \
    'echo "  \\____| \\___/|_| \\_\\_|  |_|_/   \\_\\"' \
    'echo ""' \
    'echo "=========================================="' \
    'echo " User     : $(whoami)"' \
    'echo " Hostname : $(hostname)"' \
    'echo " Uptime   : $(uptime -p 2>/dev/null || echo N/A)"' \
    'echo " Date     : $(date)"' \
    'echo " IP       : $(hostname -I 2>/dev/null | awk '"'"'{print $1}'"'"')"' \
    'echo "=========================================="' \
    'echo ""' \
    > /etc/profile.d/gurita-banner.sh && \
    chmod +x /etc/profile.d/gurita-banner.sh

# ---------- SSH PRE-AUTH BANNER ----------
RUN printf '\n  ==========================================\n' >  /etc/ssh/banner && \
    printf '       GURITA VPS - Authorized Access Only\n' >> /etc/ssh/banner && \
    printf '  ==========================================\n\n' >> /etc/ssh/banner && \
    echo 'Banner /etc/ssh/banner' >> /etc/ssh/sshd_config && \
    rm -rf /etc/update-motd.d/* && \
    rm -f /etc/motd /etc/issue /etc/issue.net && \
    touch /etc/motd /etc/issue /etc/issue.net

# ---------- SUPERVISOR CONFIG (inline) ----------
RUN mkdir -p /var/log/supervisor && \
    printf '%s\n' \
    '[supervisord]' \
    'nodaemon=true' \
    'user=root' \
    'logfile=/var/log/supervisor/supervisord.log' \
    'pidfile=/var/run/supervisord.pid' \
    'loglevel=info' \
    '' \
    '[unix_http_server]' \
    'file=/var/run/supervisor.sock' \
    'chmod=0700' \
    '' \
    '[rpcinterface:supervisor]' \
    'supervisor.rpcinterface_factory = supervisor.rpcinterface:make_main_rpcinterface' \
    '' \
    '[supervisorctl]' \
    'serverurl=unix:///var/run/supervisor.sock' \
    '' \
    '[program:sshd]' \
    'command=/usr/sbin/sshd -D -e' \
    'autostart=true' \
    'autorestart=true' \
    'priority=10' \
    'stdout_logfile=/var/log/supervisor/sshd.log' \
    'stderr_logfile=/var/log/supervisor/sshd.err' \
    '' \
    '[program:cron]' \
    'command=/usr/sbin/cron -f' \
    'autostart=true' \
    'autorestart=true' \
    'priority=20' \
    'stdout_logfile=/var/log/supervisor/cron.log' \
    'stderr_logfile=/var/log/supervisor/cron.err' \
    '' \
    '[program:rsyslog]' \
    'command=/usr/sbin/rsyslogd -n -i /var/run/rsyslogd.pid' \
    'autostart=true' \
    'autorestart=true' \
    'priority=15' \
    'stdout_logfile=/var/log/supervisor/rsyslog.log' \
    'stderr_logfile=/var/log/supervisor/rsyslog.err' \
    '' \
    '[program:fail2ban]' \
    'command=/usr/bin/fail2ban-server -xf start' \
    'autostart=true' \
    'autorestart=true' \
    'priority=30' \
    'stdout_logfile=/var/log/supervisor/fail2ban.log' \
    'stderr_logfile=/var/log/supervisor/fail2ban.err' \
    > /etc/supervisor/conf.d/supervisord.conf

# ---------- FINAL CLEANUP ----------
RUN apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* \
           /var/cache/apt/archives/* \
           /tmp/* /var/tmp/* \
           /usr/share/doc/* \
           /usr/share/man/* \
           /usr/share/locale/* \
           /var/log/*.log \
           /var/log/apt/*

# ---------- EXPOSE ----------
EXPOSE 22 80 443

# ---------- ENTRYPOINT ----------
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
