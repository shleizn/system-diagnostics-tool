#!/bin/bash

set -e
LOG_FILE="/var/log/install_system_diagnostics.log"
exec > >(tee -a "$LOG_FILE") 2>&1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIAG_FILE=system_diag.sh
SYSTEM_DIAG_CLEANUP_FILE=system_diag_cleanup.sh
SYSTEM_DIAG_SCHEDULE=minutely

echo "[INFO] Створення директорії логів..."
mkdir -p /var/log/system_diagnostics

echo "[INFO] Встановлення необхідних пакетів..."
apt-get update
apt-get install -y smartmontools iotop dstat sysstat

echo "[INFO] Встановлення діагностичного скрипта..."
cp -v "${SCRIPT_DIR}/${SYSTEM_DIAG_FILE}" /usr/local/bin/"${SYSTEM_DIAG_FILE}"

chmod +x /usr/local/bin/${SYSTEM_DIAG_FILE}

echo "[INFO] Встановлення скрипта очищення логів..."
cp -v "${SCRIPT_DIR}/${SYSTEM_DIAG_CLEANUP_FILE}" /usr/local/bin/"${SYSTEM_DIAG_CLEANUP_FILE}"

chmod +x /usr/local/bin/system_diag_cleanup.sh

echo "[INFO] Створення systemd юнітів..."

create_unit() {
  local path="$1"
  local content="$2"

  if [[ -f "$path" ]]; then
    echo "[SKIP] $path вже існує"
  else
    echo "$content" > "$path"
    echo "[OK] Створено $path"
  fi
}

create_unit "/etc/systemd/system/system-diagnostics.service" \
"[Unit]
Description=System diagnostics snapshot

[Service]
Type=oneshot
ExecStart=/usr/local/bin/system_diag.sh"

create_unit "/etc/systemd/system/system-diagnostics.timer" \
"[Unit]
Description=Run system diagnostics regularly

[Timer]
OnCalendar=${SYSTEM_DIAG_SCHEDULE}
Persistent=true

[Install]
WantedBy=timers.target"

create_unit "/etc/systemd/system/system-diagnostics-cleanup.service" \
"[Unit]
Description=Cleanup old system diagnostic logs

[Service]
Type=oneshot
ExecStart=/usr/local/bin/system_diag_cleanup.sh"

create_unit "/etc/systemd/system/system-diagnostics-cleanup.timer" \
"[Unit]
Description=Daily cleanup of old diagnostic logs

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target"

echo "[INFO] Перезавантаження systemd daemon та активація таймерів..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now system-diagnostics.timer
systemctl enable --now system-diagnostics-cleanup.timer

echo "[✅] Установка завершена успішно. Лог: $LOG_FILE"
