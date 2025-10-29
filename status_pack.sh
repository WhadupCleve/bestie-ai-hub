#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
./boot.sh >/dev/null
TS=$(date -u +'%Y%m%d_%H%M%S')
mkdir -p outputs
~/bestie_ai/status.sh > outputs/STATUS_${TS}.txt
tail -n 50 HEALTH.log > outputs/HEALTH_${TS}.txt
./sync.sh
echo "✅ Status pack saved & synced at $TS"
