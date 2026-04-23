#!/usr/bin/env bash
# Checkmate EC2 Bootstrap Script (Ubuntu 24.04 LTS)
# 신규 인스턴스에서 최초 1회 실행. idempotent 지향.
set -euo pipefail

APP_USER="ubuntu"
APP_DIR="/home/${APP_USER}/checkmate"
WEB_ROOT="/var/www/checkmate"
RELEASES_DIR="/var/www/checkmate-releases"
LOG_DIR="${APP_DIR}/logs"
NODE_VERSION="20"

# ── 시스템 패키지 ─────────────────────────────────────────────
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y curl git build-essential ca-certificates gnupg ufw

# ── Node.js 20 (NodeSource) ───────────────────────────────────
if ! command -v node >/dev/null 2>&1; then
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}.x" | sudo -E bash -
  sudo apt-get install -y nodejs
fi
echo "Node: $(node -v), npm: $(npm -v)"

# ── PM2 ──────────────────────────────────────────────────────
if ! command -v pm2 >/dev/null 2>&1; then
  sudo npm install -g pm2@latest
fi
pm2 --version

# ── Nginx ────────────────────────────────────────────────────
sudo apt-get install -y nginx
sudo systemctl enable --now nginx

# ── Certbot ──────────────────────────────────────────────────
sudo apt-get install -y certbot python3-certbot-nginx

# ── (선택) Redis — BullMQ 워커 구현 후 주석 해제 ───────────────
# sudo apt-get install -y redis-server
# sudo systemctl enable --now redis-server

# ── 디렉토리 초기화 ───────────────────────────────────────────
sudo mkdir -p "${WEB_ROOT}" "${RELEASES_DIR}"
sudo chown -R "${APP_USER}:${APP_USER}" "${WEB_ROOT}" "${RELEASES_DIR}"

mkdir -p "${APP_DIR}" "${LOG_DIR}"

# ── UFW 방화벽 ───────────────────────────────────────────────
# 8080 은 열지 않음 — Nginx가 localhost:8080 으로만 프록시
sudo ufw allow OpenSSH      # 22
sudo ufw allow 'Nginx Full' # 80 + 443
sudo ufw --force enable
sudo ufw status

# ── PM2 부팅 시 자동 시작 등록 ────────────────────────────────
pm2 startup systemd -u "${APP_USER}" --hp "/home/${APP_USER}" || true

cat <<EOF

============================================================
  Checkmate EC2 초기화 완료

  다음 단계:
  1. 백엔드 리포지토리 클론
       git clone <backend-repo-url> ${APP_DIR}/checkmate-backend

  2. 환경변수 파일 배치 (절대 git 커밋 금지)
       ${APP_DIR}/checkmate-backend/.env

  3. Nginx 설정 연결 (백엔드 최초 배포 후 scripts/, deploy/ 생성됨)
       sudo ln -s ${APP_DIR}/deploy/nginx/checkmate.conf \\
                  /etc/nginx/sites-available/checkmate
       sudo ln -s /etc/nginx/sites-available/checkmate \\
                  /etc/nginx/sites-enabled/checkmate
       sudo rm -f /etc/nginx/sites-enabled/default
       sudo nginx -t && sudo systemctl reload nginx

  4. HTTPS 발급 (도메인 DNS A 레코드 연결 후)
       sudo certbot --nginx -d <도메인> -d www.<도메인>

  5. PM2 첫 기동 (백엔드 최초 배포 후)
       pm2 start ${APP_DIR}/deploy/pm2/ecosystem.config.cjs
       pm2 save
============================================================
EOF
