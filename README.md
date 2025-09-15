Here’s a professional **README.md** for your script:

---

# 🚀 EC2 Ubuntu Dependency Bootstrap Script

This script automates the setup of a **production-ready Ubuntu 24.04 LTS (Noble Numbat)** server on **AWS EC2** with all common dependencies for modern web applications.

It includes **system updates, developer tools, Node.js, MongoDB, Python, Docker, Nginx, and security hardening**.

---

## 📋 Features

✅ System update & upgrade
✅ Core utilities (curl, git, unzip, fail2ban, htop, etc.)
✅ Node.js (LTS) + npm + PM2 process manager
✅ MongoDB **8.0** (latest stable for Ubuntu Noble)
✅ Python 3 + pip
✅ Docker + Docker Compose plugin
✅ Nginx (reverse proxy ready)
✅ UFW firewall configuration (SSH + Nginx)
✅ Service health checks & version logging

---

## 📂 Script Location

Save the script as:

```bash
ec2-bootstrap.sh
```

Make it executable:

```bash
chmod +x ec2-bootstrap.sh
```

Run it:

```bash
./ec2-bootstrap.sh
```

> ⚠️ Recommended: Run as **ubuntu user** with **sudo privileges**.

---

## 📝 Logging

All installation logs are saved in:

```
/var/log/ec2-bootstrap.log
```

This helps with debugging if something fails.

---

## 🔍 Health Checks

At the end of the script, it verifies:

* Installed versions of Node.js, npm, PM2, Python, pip, Docker, and Nginx.
* Running services: `mongod`, `nginx`, and `docker`.

---

## ⚡ Installed Versions Example

```bash
===== Installed Versions =====
[OK] node -> v20.x.x
[OK] npm -> 10.x.x
[OK] pm2 -> 5.x.x
[OK] python3 -> Python 3.12.x
[OK] pip3 -> pip 24.x
[OK] docker -> Docker version 27.x
[OK] nginx -> nginx version: nginx/1.24.x

===== Service Status =====
[OK] mongod service is running
[OK] nginx service is running
[OK] docker service is running
```

---

## 🔒 Security Notes

* **UFW firewall** allows only:

  * `OpenSSH` (for SSH access)
  * `Nginx Full` (HTTP + HTTPS)
* **fail2ban** is installed to protect against brute-force attacks.

---

## 🛠️ Customization

You can modify this script to:

* Install additional programming languages (Go, Java, Rust).
* Add CI/CD tools (Jenkins, GitHub Runner).
* Configure SSL certificates with **Certbot**.

---

## 👨‍💻 Author

**DevOps Standard (2025 Edition)**
Designed for **production-ready EC2 Ubuntu setups**.

---

Would you like me to also create a **copy-paste version of this README.md** with code blocks formatted exactly so you can drop it into GitHub without editing?
