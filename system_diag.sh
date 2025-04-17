#!/bin/bash

OUT_DIR="/var/log/system_diagnostics"
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
OUT_FILE="${OUT_DIR}/diag_${TIMESTAMP}.log"

mkdir -p "$OUT_DIR"

{
  echo "==== SYSTEM DIAGNOSTIC ($TIMESTAMP) ===="
  echo

  echo "==== UPTIME ===="
  uptime
  echo

  echo "==== TOP (short) ===="
  top -b -n 1 | head -15
  echo

  echo "==== FREE MEMORY ===="
  free -h
  echo

  echo "==== DISK USAGE ===="
  df -h | grep -v tmpfs
  echo

  echo "==== IOSTAT (short) ===="
  iostat -xz 1 1 | head -30 || echo "iostat unavailable"
  echo

  echo "==== IOTOP (top consumers) ===="
  iotop -b -n 3 -d 1 | head -20 || echo "iotop unavailable"
  echo

  echo "==== DSTAT (brief) ===="
  dstat -cdngytlm 1 1 || echo "dstat unavailable"
  echo

  echo "==== JOURNAL ERRORS (priority >= 3) ===="
  journalctl -p 3 -n 20 --no-pager || echo "journalctl unavailable"
  echo

  echo "==== DMESG (tail 50) ===="
  dmesg | tail -n 50
  echo

  echo "==== SMART (nvme0n1) short ===="
  smartctl -a /dev/nvme0n1 | grep -E "Overall|Percentage|Power_On_Hours|Unsafe_Shutdowns" || echo "smartctl unavailable"
  echo

  echo "==== SMART (sda) short ===="
  smartctl -a /dev/sda | grep -E "Reallocated_Sector_Ct|Power_On_Hours|Temperature_Celsius|Offline_Uncorrectable" || echo "smartctl unavailable"
  echo
} > "$OUT_FILE"
