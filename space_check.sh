#!/data/data/com.termux/files/usr/bin/bash
set -e
echo "📦 Storage (home):"
df -h ~ | awk 'NR==1 || NR==2'
echo
echo "🗂  Outputs size:"
du -sh ~/bestie_ai/outputs 2>/dev/null || echo "outputs/ (none)"
