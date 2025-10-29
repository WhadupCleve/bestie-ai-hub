#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
TS=$(date -u +'%Y%m%d_%H%M%S')
cp .env ".env.backup.$TS"
echo "✅ Env backed up to .env.backup.$TS"
