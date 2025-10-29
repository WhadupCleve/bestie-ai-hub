#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
# Keep a protected backup of the real .env if not already saved this session
[ -f .env ] && [ ! -f .env.disabled ] && cp -p .env .env.disabled
# Write a minimal placeholder that intentionally lacks keys
cat > .env <<'ENV'
# SAFE MODE PLACEHOLDER (no secrets)
# Keeping CLI loadable but API calls will refuse gracefully.
ENV
echo "🛡️  SAFE MODE is ON — API keys removed from runtime .env"
