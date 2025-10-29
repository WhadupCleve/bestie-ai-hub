#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
git pull --rebase origin main || true
git add -A
git commit -m "mobile sync $(date -u +'%Y-%m-%d %H:%M:%S UTC')" || true
git push -u origin main
