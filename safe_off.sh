#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
if [ -f .env.disabled ]; then
  mv -f .env.disabled .env
  echo "✅ SAFE MODE is OFF — real .env restored"
else
  echo "ℹ️  No .env.disabled found (nothing to restore)."
fi
