#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
while true; do
  date -u +"%Y-%m-%d %H:%M:%S UTC — watcher tick" >> HEALTH.log
  ./auto_health.sh || echo "$(date -u) — health FAILED" >> HEALTH.log
  sleep 10800  # 3 hours
done
