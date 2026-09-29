# 🐙 GURITA VPS

Lightweight Ubuntu 22.04 server container dengan SSH, banner custom, dan multi-service (cron, rsyslog, fail2ban) yang dikelola oleh **supervisord** — tanpa perlu `--privileged` dan tanpa systemd.

![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?logo=ubuntu&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker&logoColor=white)
![Size](https://img.shields.io/badge/Size-~220MB-blue)
![License](https://img.shields.io/badge/License-MIT-green)

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
