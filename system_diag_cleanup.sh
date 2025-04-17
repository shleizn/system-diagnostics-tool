#!/bin/bash

find /var/log/system_diagnostics/ -type f -name 'diag_*.log' -mtime +7 -delete