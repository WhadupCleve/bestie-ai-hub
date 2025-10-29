#!/data/data/com.termux/files/usr/bin/bash
set -e
cd ~/bestie_ai
[ -n "$VIRTUAL_ENV" ] || source .venv/bin/activate
set -a; source .env; set +a
echo "✅ Boot OK — venv + .env loaded"
