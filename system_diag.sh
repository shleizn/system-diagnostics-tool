#!/bin/bash

OUT_DIR="/var/log/system_diagnostics"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUT_FILE="${OUT_DIR}/diag_${TIMESTAMP}.log"

mkdir -p "$OUT_DIR"

{
  echo "==== START SYSTEM DIAGNOSTIC ===="
  echo

  echo "==== DATE ===="
  date
  echo

  echo "==== UPTIME ===="
  uptime
  echo

  echo "==== TOP (snapshot) ===="
  top -b -n 1 | head -30
  echo

  echo "==== FREE MEMORY ===="
  free -h
  echo

  echo "==== DISK USAGE ===="
  df -h
  echo

  echo "==== IOSTAT ===="
  iostat -xz 1 1 2>/dev/null || echo "iostat not available"
  echo

  echo "==== IOTOP (5s) ===="
  iotop -b -n 5 -d 1 2>/dev/null || echo "iotop not available or needs root access"
  echo

  echo "==== DSTAT (5s) ===="
  dstat -cdngytlm --tcp --udp 5 1 2>/dev/null || echo "dstat not available"
  echo

  echo "==== JOURNAL (last 100 lines, priority >= 4) ===="
  journalctl -p 4 -n 100 --no-pager
  echo

  echo "==== DMESG (last 100 lines) ===="
  dmesg | tail -100
  echo

  echo "==== SMART: /dev/nvme0n1 ===="
  smartctl -a /dev/nvme0n1 2>/dev/null || echo "smartctl failed or not available for /dev/nvme0n1"
  echo

  echo "==== SMART: /dev/sda ===="
  smartctl -a /dev/sda 2>/dev/null || echo "smartctl failed or not available for /dev/sda"
  echo

  echo "==== END ===="
} > "$OUT_FILE"
