#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
while true; do
  date -u +"%Y-%m-%d %H:%M:%S UTC — watcher tick" >> HEALTH.log
  ./auto_health.sh || echo "$(date -u) — health FAILED" >> HEALTH.log
  sleep 10800  # 3 hours
done

# router health ping
~/bestie_ai/router.sh "ping" >/dev/null 2>&1 || echo "$(date -u +"0.000000 
# router health ping
~/bestie_ai/router.sh "ping" >/dev/null 2>&1 || echo "$(date -u +\"%F %T UTC\") — router offline" >> HEALTH.log


# router health ping
~/bestie_ai/router.sh "ping" >/dev/null 2>&1 || echo "$(date -u +\"%F %T UTC\") — router offline" >> ~/bestie_ai/HEALTH.log

