#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd ~/bestie_ai

echo "🧹 Panic scrub starting (local only)…"
# Stop local server if running
pkill -f "http.server" 2>/dev/null || true

# Keep secrets + scripts; scrub volatile stuff
rm -f HEALTH.log
rm -f outputs/*.html outputs/*.md outputs/*.tsv outputs/*.csv 2>/dev/null || true
find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true

echo "✅ Done. Your .env and /Download/BestieAI/ ZIPs are untouched."
