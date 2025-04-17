# system-diagnostics

🩺 **System Diagnostics Monitor** — набір Bash-скриптів та systemd-юнітів для автоматичного збору діагностичної інформації про систему Linux у фоновому режимі.

---

## 🧰 Що входить

- `install_system_diagnostics.sh` — інсталятор, який:
  - встановлює всі необхідні утиліти (`smartmontools`, `iotop`, `dstat`, `sysstat`)
  - розміщує Bash-скрипти (`system_diag.sh`, `system_diag_cleanup.sh`)
  - створює та активує systemd юніти (`system-diagnostics.service`, `*.timer`)
  - налаштовує ротацію логів (очищення логів старших за 7 днів)
  - веде лог установки в `/var/log/install_system_diagnostics.log`

- `system_diag.sh` — основний скрипт збору інформації:
  - top, memory, disk, iostat, iotop, dstat, journalctl, dmesg
  - SMART-статус дисків: `/dev/nvme0n1` та `/dev/sda`

- `system_diag_cleanup.sh` — скрипт для прибирання логів старших за 7 днів

---

## 🚀 Встановлення

```bash
sudo bash install_system_diagnostics.sh
```

Після запуску:
- кожну хвилину збиратиметься системна інформація в `/var/log/system_diagnostics/`
- щодня видалятимуться логи старші за 7 днів
- все працює у фоновому режимі завдяки systemd

---

## 🗂 Приклади файлів

```
/usr/local/bin/system_diag.sh
/usr/local/bin/system_diag_cleanup.sh
/etc/systemd/system/system-diagnostics.{service,timer}
/etc/systemd/system/system-diagnostics-cleanup.{service,timer}
/var/log/system_diagnostics/diag_*.log
/var/log/install_system_diagnostics.log
```

---

## 🔧 Перевірити статус

```bash
systemctl list-timers --all | grep diagnostics
journalctl -u system-diagnostics.service
```

---

## 🧼 Деінсталяція

```bash
sudo systemctl disable --now system-diagnostics.timer system-diagnostics-cleanup.timer
sudo rm /usr/local/bin/system_diag*.sh
sudo rm /etc/systemd/system/system-diagnostics*.{service,timer}
sudo systemctl daemon-reload
```

---

## 📄 Ліцензія

MIT © 2025
