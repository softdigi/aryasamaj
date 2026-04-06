# Arya Samaj — Deployment Guide

Complete instructions for provisioning, configuring, and deploying the Arya Samaj platform (Laravel backend + Flutter Android app) to a production Ubuntu 22.04 server.

---

## Table of Contents

1. [Server Requirements](#1-server-requirements)
2. [Initial Server Setup](#2-initial-server-setup)
3. [Installing System Dependencies](#3-installing-system-dependencies)
4. [Laravel Backend Setup](#4-laravel-backend-setup)
5. [Nginx & PHP-FPM Configuration](#5-nginx--php-fpm-configuration)
6. [Supervisor — Queue Workers & Horizon](#6-supervisor--queue-workers--horizon)
7. [Log Rotation](#7-log-rotation)
8. [SSL Certificate (Let's Encrypt)](#8-ssl-certificate-lets-encrypt)
9. [Zero-Downtime Deployments](#9-zero-downtime-deployments)
10. [Flutter Android Build & Release](#10-flutter-android-build--release)
11. [Environment Variables Reference](#11-environment-variables-reference)
12. [Rollback Procedure](#12-rollback-procedure)

---

## 1. Server Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| OS       | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| CPU      | 2 vCPU | 4 vCPU |
| RAM      | 2 GB   | 4 GB |
| Disk     | 20 GB SSD | 40 GB SSD |
| Ports    | 22, 80, 443 | 22, 80, 443 |

**Software stack:** PHP 8.2, MySQL 8.0, Redis 7, Nginx, Composer 2, Supervisor, Node 20 (for frontend assets)

---

## 2. Initial Server Setup

```bash
# Create a deploy user (optional but recommended)
adduser deploy
usermod -aG sudo deploy

# Harden SSH (edit /etc/ssh/sshd_config)
# PermitRootLogin no
# PasswordAuthentication no
systemctl restart sshd

# Basic firewall
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable
```

---

## 3. Installing System Dependencies

```bash
# Update packages
apt update && apt upgrade -y

# PHP 8.2 and required extensions
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-mysql php8.2-redis \
    php8.2-mbstring php8.2-xml php8.2-bcmath php8.2-curl php8.2-zip \
    php8.2-intl php8.2-gd php8.2-imagick php8.2-opcache

# MySQL 8.0
apt install -y mysql-server
mysql_secure_installation

# Redis
apt install -y redis-server
systemctl enable --now redis-server

# Nginx
apt install -y nginx
systemctl enable nginx

# Composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Node.js 20 (for Vite/asset compilation)
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs

# Supervisor
apt install -y supervisor
systemctl enable --now supervisor

# Certbot (Let's Encrypt)
apt install -y certbot python3-certbot-nginx
```

---

## 4. Laravel Backend Setup

### Clone the repository

```bash
cd /var/www
git clone https://github.com/softdigi/aryasamaj.git aryasamaj
chown -R www-data:www-data /var/www/aryasamaj
chmod -R 775 /var/www/aryasamaj/storage /var/www/aryasamaj/bootstrap/cache
```

### Configure environment

```bash
cp /var/www/aryasamaj/.env.example /var/www/aryasamaj/.env
# Edit .env with your production values (see Section 11)
nano /var/www/aryasamaj/.env
```

### Install dependencies and bootstrap

```bash
cd /var/www/aryasamaj

# PHP dependencies (no dev packages in production)
composer install --no-dev --optimize-autoloader --no-interaction

# Generate application key
php8.2 artisan key:generate

# Create database and run migrations
mysql -u root -p -e "CREATE DATABASE aryasamaj CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p -e "CREATE USER 'aryasamaj'@'localhost' IDENTIFIED BY '<strong_password>';"
mysql -u root -p -e "GRANT ALL ON aryasamaj.* TO 'aryasamaj'@'localhost';"

php8.2 artisan migrate --force
php8.2 artisan db:seed --class=AdminSeeder --force
php8.2 artisan db:seed --class=FeatureSeeder --force
php8.2 artisan db:seed --class=MemberCategorySeeder --force

# Create public storage symlink
php8.2 artisan storage:link

# Build production caches
php8.2 artisan config:cache
php8.2 artisan route:cache
php8.2 artisan view:cache
php8.2 artisan optimize
```

---

## 5. Nginx & PHP-FPM Configuration

### PHP-FPM pool

```bash
# Disable the default www pool
mv /etc/php/8.2/fpm/pool.d/www.conf /etc/php/8.2/fpm/pool.d/www.conf.disabled

# Install the Arya Samaj pool
cp /var/www/aryasamaj/infra/php-fpm-pool.conf /etc/php/8.2/fpm/pool.d/aryasamaj.conf

# Verify and reload
php-fpm8.2 -t
systemctl reload php8.2-fpm
```

### Nginx virtual host

```bash
cp /var/www/aryasamaj/infra/nginx-aryasamaj.conf /etc/nginx/sites-available/aryasamaj
ln -s /etc/nginx/sites-available/aryasamaj /etc/nginx/sites-enabled/aryasamaj

# Remove default site
rm -f /etc/nginx/sites-enabled/default

# Verify and reload
nginx -t
systemctl reload nginx
```

> **Note:** You must obtain an SSL certificate (Section 8) before Nginx can start with the HTTPS block. Temporarily comment out SSL directives for the initial certificate request.

---

## 6. Supervisor — Queue Workers & Horizon

```bash
# Install both Supervisor config files
cp /var/www/aryasamaj/infra/supervisor-worker.conf  /etc/supervisor/conf.d/aryasamaj-worker.conf
cp /var/www/aryasamaj/infra/supervisor-horizon.conf /etc/supervisor/conf.d/aryasamaj-horizon.conf

# Reload Supervisor
supervisorctl reread
supervisorctl update

# Start processes
supervisorctl start aryasamaj-worker:*
supervisorctl start aryasamaj-horizon:*

# Verify
supervisorctl status
```

Horizon dashboard is available at `https://aryasamaj.site/horizon` (admin-only, IP-restricted by Nginx).

---

## 7. Log Rotation

```bash
cp /var/www/aryasamaj/infra/logrotate-aryasamaj /etc/logrotate.d/aryasamaj

# Test the configuration
logrotate -d /etc/logrotate.d/aryasamaj

# Force a rotation to verify
logrotate -f /etc/logrotate.d/aryasamaj
```

---

## 8. SSL Certificate (Let's Encrypt)

```bash
# Obtain certificate (Nginx plugin handles temporary server blocks automatically)
certbot --nginx -d aryasamaj.site -d www.aryasamaj.site \
    --email admin@aryasamaj.site --agree-tos --no-eff-email

# Auto-renewal is configured by the certbot package; verify the timer
systemctl status certbot.timer

# Test renewal
certbot renew --dry-run
```

---

## 9. Zero-Downtime Deployments

The `deploy.sh` script at the root of the repository performs all deployment steps without downtime:

```bash
# Run from the server as root or sudo
bash /var/www/aryasamaj/deploy.sh
```

**What `deploy.sh` does:**

| Step | Action |
|------|--------|
| 1 | `git pull origin main` — fetches latest code |
| 2 | `composer install --no-dev` — updates PHP dependencies |
| 3 | `artisan migrate --force` — runs new migrations |
| 4 | `artisan config:cache` / `route:cache` / `view:cache` — rebuilds caches |
| 5 | Sets `www-data` ownership and `775` permissions on storage |
| 6 | `artisan horizon:terminate` — gracefully stops Horizon (Supervisor restarts it) |
| 7 | `supervisorctl restart` — restarts all queue workers |
| 8 | `systemctl reload php8.2-fpm` — reloads PHP-FPM for INI changes |

> PHP-FPM reload is graceful (in-flight requests complete before workers are recycled). Nginx is never restarted, so there is no downtime for static assets.

---

## 10. Flutter Android Build & Release

### Prerequisites

- Flutter SDK ≥ 3.0.0 installed locally
- Java 17 (required by Gradle)
- Android SDK (API level 34)
- A signed release keystore

### Create a release keystore

```bash
keytool -genkey -v \
    -keystore ~/keystores/aryasamaj-release.jks \
    -alias aryasamaj \
    -keyalg RSA -keysize 2048 \
    -validity 10000
```

### Configure signing

Create `arya_samaj_app/android/key.properties` (**never commit this file**):

```properties
storePassword=<your_store_password>
keyPassword=<your_key_password>
keyAlias=aryasamaj
storeFile=/home/<user>/keystores/aryasamaj-release.jks
```

Verify `.gitignore` contains `android/key.properties` (already included).

### Build the release APK / App Bundle

```bash
cd arya_samaj_app

# Get dependencies
flutter pub get

# Build a release App Bundle (recommended for Play Store)
flutter build appbundle --release

# Or build a release APK (for direct distribution)
flutter build apk --release --split-per-abi

# Outputs:
# AppBundle: build/app/outputs/bundle/release/app-release.aab
# APKs:      build/app/outputs/apk/release/app-*-release.apk
```

### Play Store upload

1. Sign in to the [Google Play Console](https://play.google.com/console).
2. Navigate to your app → **Release** → **Production**.
3. Upload `app-release.aab`.
4. Fill in release notes (Hindi/English) and roll out.

---

## 11. Environment Variables Reference

Key variables required in `/var/www/aryasamaj/.env`:

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_ENV` | Environment | `production` |
| `APP_KEY` | 32-byte base64 key (generated by `artisan key:generate`) | `base64:...` |
| `APP_URL` | Public HTTPS URL | `https://aryasamaj.site/app_api` |
| `DB_HOST` | MySQL host | `127.0.0.1` |
| `DB_DATABASE` | Database name | `aryasamaj` |
| `DB_USERNAME` | Database user | `aryasamaj` |
| `DB_PASSWORD` | Database password | *(strong password)* |
| `REDIS_HOST` | Redis host | `127.0.0.1` |
| `REDIS_PASSWORD` | Redis password | `null` or set value |
| `QUEUE_CONNECTION` | Queue driver | `redis` |
| `CACHE_STORE` | Cache driver | `redis` |
| `FILESYSTEM_DISK` | File storage | `public` or `r2` |
| `CLOUDFLARE_R2_ACCESS_KEY_ID` | R2 credentials | *(from Cloudflare dashboard)* |
| `CLOUDFLARE_R2_SECRET_ACCESS_KEY` | R2 secret | *(from Cloudflare dashboard)* |
| `CLOUDFLARE_R2_BUCKET` | R2 bucket name | `aryasamaj-assets` |
| `CLOUDFLARE_R2_ENDPOINT` | R2 endpoint | `https://<account>.r2.cloudflarestorage.com` |
| `CDN_URL` | Public CDN URL for assets | `https://cdn.aryasamaj.site` |
| `MAIL_MAILER` | Mail driver | `smtp` |
| `RAZORPAY_KEY_ID` | Razorpay API key | *(from Razorpay dashboard)* |
| `RAZORPAY_KEY_SECRET` | Razorpay secret | *(from Razorpay dashboard)* |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging key | *(from Firebase console)* |
| `TWILIO_SID` | Twilio account SID (for OTP SMS) | `AC...` |
| `TWILIO_TOKEN` | Twilio auth token | *(from Twilio console)* |
| `TWILIO_FROM` | Twilio sender number | `+1...` |

---

## 12. Rollback Procedure

If a deployment introduces a regression:

```bash
cd /var/www/aryasamaj

# 1. Identify the last known-good commit
git --no-pager log --oneline -10

# 2. Roll back to that commit
git checkout <commit-sha>

# 3. Re-run the deployment steps (skip migration if rolling back a schema change)
composer install --no-dev --optimize-autoloader --no-interaction
php8.2 artisan config:cache
php8.2 artisan route:cache
php8.2 artisan view:cache
php8.2 artisan optimize

# 4. Restart workers
php8.2 artisan horizon:terminate || true
supervisorctl restart aryasamaj-horizon:*
supervisorctl restart aryasamaj-worker:*
systemctl reload php8.2-fpm

# 5. To roll back a migration (use with caution in production)
php8.2 artisan migrate:rollback --step=1
```

> **Tip:** Tag every production release (`git tag v1.x.x`) so rollbacks are straightforward.
