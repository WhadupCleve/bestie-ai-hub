#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null
echo -n "$(date -u +"%Y-%m-%d %H:%M:%S UTC") — " >> HEALTH.log
out=$(python bestie.py "ping" | head -n 1 || true)
[ -n "$out" ] && echo "AI OK" >> HEALTH.log || echo "AI FAIL" >> HEALTH.log
tail -n 3 HEALTH.log
