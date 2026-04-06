#!/usr/bin/env bash
# =============================================================================
# deploy.sh — Arya Samaj App Zero-Downtime Deployment Script
# Usage: bash deploy.sh
# Run from: /var/www/aryasamaj
# =============================================================================
set -euo pipefail

APP_DIR="/var/www/aryasamaj"
PHP="php8.2"
ARTISAN="$PHP $APP_DIR/artisan"

echo "──────────────────────────────────────────────"
echo " Arya Samaj — Deployment started at $(date)"
echo "──────────────────────────────────────────────"

cd "$APP_DIR"

# 1. Pull latest code
echo "[1/8] Pulling latest code from GitHub..."
git pull origin main

# 2. Install / update Composer dependencies (no dev packages)
echo "[2/8] Installing Composer dependencies..."
composer install --no-dev --optimize-autoloader --no-interaction

# 3. Run database migrations
echo "[3/8] Running database migrations..."
$ARTISAN migrate --force

# 4. Clear & rebuild all caches
echo "[4/8] Rebuilding application caches..."
$ARTISAN config:cache
$ARTISAN route:cache
$ARTISAN view:cache
$ARTISAN optimize

# 5. Ensure correct file permissions
echo "[5/8] Setting file permissions..."
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# 6. Gracefully stop Horizon (it will restart via Supervisor)
echo "[6/8] Terminating Horizon workers gracefully..."
$ARTISAN horizon:terminate || true

# 7. Restart Supervisor workers
echo "[7/8] Restarting Supervisor processes..."
supervisorctl restart aryasamaj-horizon:* || true
supervisorctl restart aryasamaj-worker:*  || true

# 8. Reload PHP-FPM (pick up any INI changes)
echo "[8/8] Reloading PHP-FPM..."
systemctl reload php8.2-fpm

echo ""
echo "✅  Deploy complete at $(date)"
echo "──────────────────────────────────────────────"
