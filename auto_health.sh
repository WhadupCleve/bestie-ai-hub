#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null
# run the health check (appends to HEALTH.log)
./health.sh >/dev/null
# trim log to last 500 lines so it never grows too big
tail -n 500 HEALTH.log > HEALTH.log.tmp && mv HEALTH.log.tmp HEALTH.log
