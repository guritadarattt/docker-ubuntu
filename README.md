# docker-ubuntu-server
Minimal Ubuntu Server Docker Image (Headless, No Desktop Environment)

## Description
Docker image berbasis **Ubuntu 22.04 Server** tanpa desktop environment (headless).
Dirancang ringan dan siap pakai untuk kebutuhan server seperti SSH remote access,
networking tools, build essentials, Python, database clients, dan lain-lain.

## Features
- 🐧 Base: Ubuntu 22.04 (amd64)
- 🪶 Ringan, tanpa GUI/desktop environment
- 🔐 SSH server siap pakai (port 22)
- 🌐 Networking tools lengkap (ping, dig, traceroute, nmap, tcpdump, dll)
- 🛠️ Build essentials (gcc, g++, make, cmake, pkg-config)
- 🐍 Python 3 + pip + venv
- 🗄️ Database clients (MySQL, PostgreSQL, Redis)
- 📦 Utilities: git, curl, wget, rsync, vim, htop, jq, tree, dll
- 🛡️ Security: ufw, fail2ban, openssl

## Usage
$ docker run -d --name ubuntu-server -p 2222:22 akarita/docker-ubuntu-server

text

## Access via SSH
$ ssh root@localhost -p 2222

text
Default password: `root` (⚠️ **segera ganti setelah login pertama!**)

Ganti password di dalam container:
$ passwd

text

## DockerHub
https://hub.docker.com/r/akarita/docker-ubuntu-server

## Docker Pull
$ docker pull akarita/docker-ubuntu-server

text

## Docker Build
$ docker build . -t docker-ubuntu-server

text

## Run dengan Volume Persisten (opsional)
$ docker run -d --name ubuntu-server
-p 2222:22
-v ubuntu-server-data:/data
akarita/docker-ubuntu-server

text

## Customization
Jika ingin mengubah timezone, edit pada Dockerfile:
```dockerfile
ENV TZ=Asia/Jakarta
Jika ingin mengubah default password root, edit:

dockerfile
RUN echo 'root:root' | chpasswd
Included Packages (ringkasan)
Kategori	Package
Core	init, systemd, dbus
Networking	net-tools, iproute2, iputils-ping, dnsutils, traceroute, nmap, tcpdump, netcat, socat
SSH	openssh-server, openssh-client
Editor	vim, nano
Monitoring	htop, iotop, sysstat, lsof, psmisc
Build	build-essential, gcc, g++, make, cmake
Python	python3, pip, venv, dev
Database Clients	mysql-client, postgresql-client, redis-tools
Utilities	git, curl, wget, rsync, jq, tree, zip, unzip, 7zip
Security	ufw, fail2ban, openssl
License
MIT License (c) 2023 Takahashi Akari
