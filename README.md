
markdown
# 🐙 GURITA VPS

Lightweight Ubuntu 22.04 server container dengan SSH, banner custom, dan multi-service (cron, rsyslog, fail2ban) yang dikelola oleh **supervisord** — tanpa perlu `--privileged` dan tanpa systemd.

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![Size](https://img.shields.io/badge/Size-~220MB-blue)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## ✨ Fitur

- ✅ **Base Ubuntu 22.04** — kompatibel dengan mayoritas tool Linux
- ✅ **Supervisord** sebagai init — ringan (~5MB), multi-service, tanpa `--privileged`
- ✅ **SSH Server** — siap remote login sejak container pertama kali jalan
- ✅ **Banner custom GURITA VPS** — ASCII art + info user/host/uptime/IP
- ✅ **Multi-service otomatis**:
  - `sshd` — SSH server
  - `cron` — scheduler
  - `rsyslog` — system log
  - `fail2ban` — proteksi brute-force
- ✅ **Default password**: `Gurita26` (bisa di-override saat build)
- ✅ **Ringan** (~220–280 MB) — jauh lebih kecil dari versi systemd
- ✅ **Best practice Docker** — jalan di Docker Swarm/K8s tanpa modifikasi

---

## 📦 Persyaratan

- Docker Engine `20.10+`
- Docker Compose `1.29+` (opsional)
- RAM minimal `256 MB` per container
- Disk kosong minimal `500 MB`

---

## 🚀 Instalasi Cepat

### 1. Clone repository

```bash
git clone https://github.com/username/gurita-vps.git
cd gurita-vps
```
2. Build image
```
bash
docker build -t gurita-vps:latest .
```
3. Jalankan container
```
bash
docker run -d \
  --name gurita-vps \
  --restart unless-stopped \
  -p 2222:22 \
  gurita-vps:latest
```
4. Login SSH
```
bash
ssh root@localhost -p 2222
```
Password default:
```
text
Gurita26
```
🎨 Tampilan Setelah Login
```
text
==========================================
          G U R I T A   V P S
==========================================

   ____  _   _ ____ ___ _____  _
  / ___|| | | |  _ \_ _|_   _|/ \
 | |  _ | | | | |_) | |  | | / _ \
 | |_| || |_| |  _ <| |  | |/ ___ \
  \____| \___/|_| \_\_|  |_|_/   \_\

==========================================
 User     : root
 Hostname : 8f3a1b2c9d4e
 Uptime   : up 2 minutes
 Date     : Mon Sep 29 10:30:00 WIB 2026
 IP       : 172.17.0.2
==========================================
```
🔐 Konfigurasi Password
Ganti password saat build (opsional)
```
bash
docker build --build-arg ROOT_PASSWORD=PasswordBaru123 -t gurita-vps:latest .
```
Ganti password setelah container jalan
```
bash
docker exec -it gurita-vps passwd root
```
⚠️ Peringatan: Ganti password default Gurita26 sebelum deploy ke production!

⚙️ Manajemen Service
Semua service dikelola oleh supervisord. Cek status:
```

bash
docker exec -it gurita-vps supervisorctl status
```
Output yang diharapkan:

```
text
cron      RUNNING   pid 12, uptime 0:05:15
fail2ban  RUNNING   pid 14, uptime 0:05:12
rsyslog   RUNNING   pid 13, uptime 0:05:14
sshd      RUNNING   pid 11, uptime 0:05:15
```
Perintah supervisord yang berguna
Perintah	Fungsi
```
supervisorctl status	Cek status semua service
supervisorctl restart sshd	Restart service SSH
supervisorctl stop cron	Hentikan service cron
supervisorctl start cron	Jalankan service cron
supervisorctl restart all	Restart semua service
supervisorctl tail -f sshd	Lihat log SSH real-time
```
Contoh pemakaian:

```
bash
docker exec -it gurita-vps supervisorctl restart sshd
```
🌐 Port yang Tersedia
Port	Service	Keterangan
22	SSH	Untuk remote login
80	HTTP	Siap untuk web server (nginx/apache)
443	HTTPS	Siap untuk web server SSL
Mapping port saat docker run:
```
bash
docker run -d \
  --name gurita-vps \
  -p 2222:22 \
  -p 8080:80 \
  -p 8443:443 \
  gurita-vps:latest
```
📂 Struktur Direktori Penting
Path	Isi
/etc/ssh/sshd_config	Konfigurasi SSH server
/etc/ssh/banner	Banner pre-auth SSH
/etc/profile.d/gurita-banner.sh	Banner post-login
/etc/supervisor/conf.d/supervisord.conf	Konfigurasi supervisord
/var/log/supervisor/	Log semua service
/etc/fail2ban/	Konfigurasi fail2ban
🧪 Testing
Test SSH
```
bash
ssh root@localhost -p 2222
```
# Masukkan password: Gurita26
Test cron
```
bash
docker exec -it gurita-vps bash -c "echo '* * * * * echo hello >> /tmp/cron-test.log' | crontab -"
```
# Tunggu 1-2 menit
```
docker exec -it gurita-vps cat /tmp/cron-test.log
Test fail2ban
```
bash
docker exec -it gurita-vps fail2ban-client status
docker exec -it gurita-vps fail2ban-client status sshd
```
🐳 Docker Compose (Opsional)
Buat file docker-compose.yml:
```
yaml
version: "3.8"

services:
  gurita-vps:
    build:
      context: .
      args:
        ROOT_PASSWORD: Gurita26
    image: gurita-vps:latest
    container_name: gurita-vps
    restart: unless-stopped
    ports:
      - "2222:22"
      - "8080:80"
      - "8443:443"
    volumes:
      - gurita-data:/root
    environment:
      - TZ=Asia/Jakarta

volumes:
  gurita-data:
```
Jalankan:
```
bash
docker compose up -d
docker compose logs -f
```
📊 Ukuran Image
Versi	Base	Init	Estimasi Ukuran
GURITA VPS (supervisord)	ubuntu:22.04	supervisord	~220–280 MB
Versi systemd	ubuntu:22.04	systemd	~350–450 MB
Cek ukuran image Anda:
```
bash
docker images gurita-vps:latest
```
🔧 Troubleshooting
❌ Container langsung mati
Cek log:
```
bash
docker logs gurita-vps
```
Biasanya karena:

Port 22 sudah dipakai container lain → ganti mapping (-p 2223:22)

Supervisord config error → cek /var/log/supervisor/supervisord.log

❌ Tidak bisa SSH
Pastikan container jalan:
```
bash
docker ps
```
Cek service sshd:
```
bash
docker exec -it gurita-vps supervisorctl status sshd
```
Cek port:
```
bash
docker port gurita-vps
```
❌ Banner tidak muncul
Pastikan login sebagai shell interaktif:

```
bash
ssh -t root@localhost -p 2222
```
-t memaksa alokasi TTY, agar /etc/profile.d/gurita-banner.sh dijalankan.

❌ supervisorctl error "connection refused"
Cek socket supervisord:
```
bash
docker exec -it gurita-vps ls -la /var/run/supervisor.sock
```
Jika tidak ada, berarti supervisord belum jalan sempurna. Cek log:
```
bash
docker exec -it gurita-vps cat /var/log/supervisor/supervisord.log
```
🔒 Keamanan untuk Production
Sebelum deploy ke production, lakukan hal berikut:

Ganti password default Gurita26:
```
bash
docker exec -it gurita-vps passwd root
```
Gunakan SSH key daripada password:
```
bash
docker exec -it gurita-vps bash -c "
  mkdir -p /root/.ssh && \
  echo 'ssh-rsa AAAA...' > /root/.ssh/authorized_keys && \
  chmod 700 /root/.ssh && chmod 600 /root/.ssh/authorized_keys
"```
Lalu di /etc/ssh/sshd_config set PasswordAuthentication no.

Ganti port SSH dari 22 ke port lain:

bash
docker run -d -p 22222:22 gurita-vps:latest
Batasi IP yang bisa SSH menggunakan firewall host.

Aktifkan fail2ban (sudah otomatis jalan via supervisord).

Backup volume /root secara berkala.

📝 Lisensi
MIT License

Copyright (c) 2023 Gurita Darat

Lihat file LICENSE untuk detail lengkap.

🤝 Kontribusi
Pull request selalu diterima! Untuk perubahan besar, buka issue terlebih dahulu untuk diskusi.

📞 Kontak
Author: Gurita Darat

Repo: https://github.com/username/gurita-vps

Issues: https://github.com/username/gurita-vps/issues

⭐ Jangan lupa bintangnya kalau repo ini bermanfaat!

text

---
