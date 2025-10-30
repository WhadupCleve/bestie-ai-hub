#!/data/data/com.termux/files/usr/bin/bash
set -e; cd ~/bestie_ai; ./boot.sh >/dev/null
TS=$(date -u +'%Y%m%d_%H%M%S')
~/bestie_ai/status.sh > "outputs/STATUS_$TS.txt"
./sync.sh
echo "✅ Snapshot: outputs/STATUS_$TS.txt"
